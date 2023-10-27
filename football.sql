-- Checking everything --
SELECT *
FROM ProjectFootball.dbo.football

--- Changing NULLS to zeroes only if player is present ---

SELECT *,
       CASE
           WHEN rating IS NOT NULL AND goals IS NULL THEN 0
		   WHEN rating IS NULL THEN NULL
           ELSE goals
       END AS goalsfixed,
       CASE
           WHEN rating IS NOT NULL AND assists IS NULL THEN 0
		   WHEN rating IS NULL THEN NULL
           ELSE assists
       END AS assistfixed
FROM ProjectFootball.dbo.football;

-- Adding new column for goals with nulls replaced with zeroes if player is present in game-- 
ALTER TABLE ProjectFootball.dbo.football
ADD goalsfixed int;


UPDATE ProjectFootball.dbo.football
SET goalsfixed = CASE
    WHEN rating IS NOT NULL AND goals IS NULL THEN 0
    WHEN rating IS NULL THEN NULL
    ELSE goals
END;


--adding new column for assist with nulls replaced with zeroes if player is present in game-- 
ALTER TABLE ProjectFootball.dbo.football
ADD assistfixed int;


UPDATE ProjectFootball.dbo.football
SET assistfixed = CASE
    WHEN rating IS NOT NULL AND assists IS NULL THEN 0
    WHEN rating IS NULL THEN NULL
    ELSE assists
END;


--Checking the table--
SELECT *
FROM ProjectFootball.dbo.football



--- Changing NULLS to zeroes only if player is present ---
SELECT *,
       CASE
           WHEN rating IS NOT NULL AND contribution IS NULL THEN 0
           WHEN rating IS NULL THEN NULL
           ELSE contribution
       END AS contributionfixed
FROM ProjectFootball.dbo.football;


--adding new column for contributions with nulls replaced with zeroes if player is present in game-- 
ALTER TABLE ProjectFootball.dbo.football
ADD contributionfixed int;


UPDATE ProjectFootball.dbo.football
SET contributionfixed = CASE
		WHEN rating IS NOT NULL AND contribution IS NULL THEN 0
        WHEN rating IS NULL THEN NULL
        ELSE contribution
END;


--Giving positions to players--
SELECT player, 
       CASE
           WHEN player IN ('salah', 'jota', 'diaz', 'nunez', 'messi', 'vinicius', 'edwards', 'gakpo', 'mbappe') THEN 'forward'
		   WHEN player IN ('de jong', 'macallister', 'gravenberch', 'kimmich', 'szoboszlai', 'endo', 'thiago', 'elliot', 'bellingham') THEN 'midfielder'
		   WHEN player IN ('allison', 'kelleher', 'adrian') THEN 'goalkeeper'
           ELSE 'defender'
       END AS position
FROM ProjectFootball.dbo.football

-- Adding new column for player position -- 
ALTER TABLE ProjectFootball.dbo.football
ADD position NVARCHAR(255);

UPDATE ProjectFootball.dbo.football
SET position = CASE
           WHEN player IN ('salah', 'jota', 'diaz', 'nunez', 'messi', 'vinicius', 'edwards', 'gakpo', 'mbappe') THEN 'forward'
		   WHEN player IN ('de jong', 'macallister', 'gravenberch', 'kimmich', 'szoboszlai', 'endo', 'thiago', 'elliot', 'bellingham') THEN 'midfielder'
		   WHEN player IN ('allison', 'kelleher', 'adrian') THEN 'goalkeeper'
           ELSE 'defender'
END;


-- For every game the goals must add together in sequence -- 
SELECT player, position, gameplayed, rating, club, game as club_game, goalsfixed, assistfixed, contributionfixed,
       SUM(goalsfixed) OVER (PARTITION BY player ORDER BY gameplayed) as accumulated_goals,
       SUM(assistfixed) OVER (PARTITION BY player ORDER BY gameplayed) as accumulated_assists,
	   SUM(contributionfixed) OVER (PARTITION BY player ORDER BY gameplayed) as accumulated_contributions
FROM ProjectFootball.dbo.football
WHERE rating IS NOT NULL
ORDER BY player, gameplayed


--number of man of the match per player
Select player, position, Count(man) as ManOfMatch, Count(rating) as MatchesPlayed
From ProjectFootball.dbo.football
WHERE player is not NULL
Group by player, position
Order by player 

--number of goals, assists and contributions per player
SELECT player, MAX(ISNULL(gameplayed, 0)) as games, position, 
    SUM(ISNULL(goalsfixed, 0)) as totalgoals,
    SUM(ISNULL(assistfixed, 0)) as totalassists,
    SUM(ISNULL(contributionfixed, 0)) as totalcontribution,
    CASE
        WHEN MAX(ISNULL(gameplayed, 0)) > 0 THEN SUM(ISNULL(goalsfixed, 0))/MAX(ISNULL(gameplayed, 0))
        ELSE 0
    END as goalspergame,
    CASE
        WHEN MAX(ISNULL(gameplayed, 0)) > 0 THEN SUM(ISNULL(assistfixed, 0))/MAX(ISNULL(gameplayed, 0))
        ELSE 0
    END as assistsgoalspergame,
    CASE
        WHEN MAX(ISNULL(gameplayed, 0)) > 0 THEN SUM(ISNULL(contributionfixed, 0))/MAX(ISNULL(gameplayed, 0))
        ELSE 0
    END as contributionpergame
FROM ProjectFootball.dbo.football
WHERE player IS NOT NULL
GROUP BY player, position
ORDER BY player;


-- Joining tables from player stats with club stats -- 
-- Filtering out players that did not play from each game --
SELECT player, foot.club, position,
	   goalsfixed as goals, 
	   assistfixed as assists, 
	   contributionfixed,
	   man, gameplayed, rating, 
	   club.goals as teamscore,
	   shots, conversion, corners, fouls, yellow, red, formation, possession,
	   club.game as club_game
FROM ProjectFootball.dbo.football foot
JOIN Projectfootball.dbo.club club
	ON foot.game = club.game
WHERE rating IS NOT NULL

select*
FROM ProjectFootball.dbo.football
WHERE rating IS NOT NULL
ORDER BY player, gameplayed


