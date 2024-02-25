-- Q.1 - How many times does the average user post?

/*
SELECT COUNT(*), AVG(COUNT(*)) OVER() AS avg_Post FROM photos
GROUP BY user_id;
*/

SELECT u.id,u.username,
       COUNT(p.id) AS total_posts,
       AVG(COUNT(p.id)) OVER () AS average_posts
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
GROUP BY u.id, u.username
order by u.id;


-- Q.2 Find the top 5 most used hashtags.
SELECT t.id AS Tag_ID,t.tag_name as Tag,count(*) AS Most_used FROM tags t
INNER JOIN photo_tags pt ON t.id = pt.tag_id
GROUP BY pt.tag_id
ORDER BY Most_used DESC
LIMIT 5;

-- Q3. Find users who have liked every single photo on the site.

SELECT count(id) FROM photos;
SELECT * FROM users u 
WHERE 257 = (SELECT count(DISTINCT(photo_id)) FROM likes l WHERE u.id = l.user_id);

SELECT u.id AS user_id, u.username, COUNT(p.id) AS total_likes
FROM users u INNER JOIN likes l ON u.id = l.user_id
INNER JOIN photos p ON l.photo_id = p.id
WHERE (
    SELECT COUNT(id) 
    FROM photos
) = (
    SELECT COUNT(DISTINCT l.photo_id)
    FROM likes l
    WHERE u.id = l.user_id
)
GROUP BY u.id, u.username;



-- Q4.Retrieve a list of users along with their usernames and the rank of their account creation, 
-- ordered by the creation date in ascending order.
    
    SELECT username, created_at AS Account_creation, RANK() OVER(ORDER BY  created_at) AS Ranks FROM users;
    
    -- Q5. List the comments made on photos with their comment texts, photo URLs, and usernames of users who 
    -- posted the comments. Include the comment count for each photo


SELECT
    p.id,
    c.comment_text,
    p.image_url,
    u.username AS commenter_username,
    pc.comment_count
FROM comments c
INNER JOIN photos p ON c.photo_id = p.id
INNER JOIN users u ON c.user_id = u.id
INNER JOIN (
    SELECT c.photo_id, COUNT(c.id) AS comment_count
    FROM comments c
    GROUP BY c.photo_id
) pc ON p.id = pc.photo_id
ORDER BY p.id, pc.comment_count DESC;

-- Q6. For each tag, show the tag name and the number of photos associated with that tag. 
-- Rank the tags by the number of photos in descending order.
SELECT
    t.tag_name,
    COUNT(pt.photo_id) AS num_photos
FROM tags t
LEFT JOIN photo_tags pt ON t.id = pt.tag_id
GROUP BY t.tag_name
ORDER BY num_photos DESC;

-- Q7 List the usernames of users who have posted photos along with the count of photos they have posted.
-- Rank them by the number of photos in descending order.

SELECT u.id,u.username,count(p.user_id) AS total_post FROM users u
INNER JOIN photos p ON u.id = p.user_id
GROUP BY u.id
ORDER BY total_post DESC;

-- Q8 Display the username of each user along with the creation date of their first posted photo 
-- and the creation date of their next posted photo.

CREATE VIEW  user_posts AS (SELECT u.id, u.username, p.created_at AS first_post_create_date, 
LEAD(p.created_at) OVER(PARTITION BY p.user_id ORDER BY p.created_at)AS next_post_create_date
FROM users u 
INNER JOIN photos p ON u.id = p.user_id);

SELECT * FROM user_posts;

SELECT * FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY id) AS post_no
FROM user_posts
) AS numbered_posts
WHERE post_no = 1;


-- Q9. For each comment, show the comment text, the username of the commenter, 
-- and the comment text of the previous comment made on the same photo.

WITH user_comment AS (SELECT p.id,u.username,LEAD (c.comment_text) OVER (PARTITION BY p.id ORDER BY c.created_at) AS photo_comment FROM users u 
INNER JOIN comments c ON u.id = c.user_id
INNER JOIN photos p ON c.photo_id = p.id)
SELECT *, LAG(photo_comment) OVER (PARTITION BY id ORDER BY username) AS previous_comment FROM user_comment
;

/*SELECT p.id,u.username, c.comment_text AS previous_photo_comment FROM users u 
INNER JOIN comments c ON u.id = c.user_id
INNER JOIN photos p ON c.photo_id = p.id
ORDER BY p.id,u.username,c.created_at;
*/

-- Q10 Show the username of each user along with the number of photos they have posted and the number of 
-- photos posted by the user before them and after them, based on the creation date.

CREATE VIEW users_posts2 AS (SELECT u.id AS user_id, u.username as user_name, count(*) AS total_post FROM users u 
INNER JOIN photos p ON u.id = p.user_id
GROUP BY p.user_id);
select * from users_posts2;
SELECT user_id, user_name,total_post, SUM(total_post) OVER (ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS sum_be_and_after FROM users_posts2 ;

