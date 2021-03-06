//create an empty table with schema

create external table mv_ratings (user_id INT, movie_id INT, rating INT, time_stamp STRING) 

row format 

delimited fields terminated by '\t' 

lines terminated by '\n' 

stored as textfile



//load this empty table with the given Movie Ratings Data 

load data local inpath '/home/public/course/rec.data' overwrite into table mv_ratings;



//sort the table by user_id and movie_id  

create table mv_ratings_sorted as 

select * 

from mv_ratings 

order by user_id, movie_id;



//creating a table with all pairs of movies that are ranked 3 or more  

create table mv_ratings_combo as 

select a.user_id, 

a.movie_id as movie_id1, 

b.movie_id as movie_id2 

from mv_ratings_sorted a join mv_ratings_sorted b on (a.user_id = b.user_id) 

where a.movie_id < b.movie_id and a.rating >= 3 and b.rating >=3;



//For each movie pair count the number of instances where a user has given both of it a rating of more than 3

create table mv_ratings_combo_count as 

select movie_id1, movie_id2, count(*) as combo_count 

from mv_ratings_combo 

group by movie_id1, movie_id2;



//below codes when run will give the top 10 movie recommendations for user 201 which he hasnt watched yet



//from the above table select only those rows where the user 201 has watched the first movie

create table mv_watched_by_201 as 

select a.movie_id1, 

a.movie_id2, 

a.combo_count, 

b.movie_id_201 

from mv_ratings_combo_count a join (select distinct movie_id as movie_id_201 from mv_ratings where user_id = 201 and rating >= 3) b on (a.movie_id1 = b.movie_id_201);



//table with distinct movies

create table all_dist_movies as

select movie_id

from mv_ratings;



//table with distinct movies watched by user 201

create table all_dist_movies_201 as

select movie_id

from mv_ratings 

where user_id = 201;



//table with distinct movies not watched by user 201

create table mv_notwatched_201 as 

select a.movie_id as movie_id_orig 

from all_dist_movies a left outer join all_dist_movies_201 b on (a.movie_id = b.movie_id) where b.movie_id is null;



//list of all movies which could be recommended to user 201 sorted by most votes together

create table mv_reco_201 as 

select a.movie_id2, a.combo_count 

from mv_watched_by_201 a join mv_notwatched_201 b on (a.movie_id2 = b.movie_id_orig) order by a.combo_count desc;



//list of top 10 movies to be recommended to user 201 => movie_id, combo_count (no. of votes)

select *

from mv_reco_201

limit 10;



//OUTPUT

movie_id 	no_of_votes

168     	254

257     	243

300     	241

151     	233

168     	224

294     	223

257     	222

168     	208

132     	205

151     	203
