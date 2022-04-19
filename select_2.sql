--количество исполнителей в каждом жанре
select g."name" as genre, count(m.id) as amount
from genre g 
join genre_musicians gm on g.id = gm.genre_id 
join musicians m on gm.musicians_id = m.id
group by genre

--количество треков, вошедших в альбомы 2019-2020 годов
select a."name" as album, count(t.id) as amount 
from albums a
join tracks t on a.id = t.id_albums 
where a."year" between 2019 and 2020
group by a."name"

--средняя продолжительность треков по каждому альбому
select a."name" as album, round(avg(t.duration), 2) as average_duration
from albums a
join tracks t on a.id = t.id_albums 
group by a."name"

--все исполнители, которые не выпустили альбомы в 2020 году
select m."name" as musicians
from musicians m 
where m."name" not in 
	(select m."name" 
	from musicians m
	join albums_musicians am on m.id = am.musicians_id 
	join albums a on a.id = am.albums_id 
	where a."year" = 2020)

--названия сборников, в которых присутствует конкретный исполнитель
select c."name" as collections
from collections c
join collections_tracks ct on c.id = ct.collections_id 
join tracks t on ct.tracks_id = t.id 
join albums a on t.id_albums = a.id 
join albums_musicians am on am.albums_id = a.id 
where am.musicians_id = 2
group by collections

--название альбомов, в которых присутствуют исполнители более 1 жанра
select a."name" as albums
from albums a 
join albums_musicians am on a.id = am.albums_id 
join genre_musicians gm on gm.musicians_id = am.musicians_id 
group by albums
having count(gm.musicians_id) > 1 

--наименование треков, которые не входят в сборники
select t."name" as tracks
from tracks t 
left join collections_tracks ct on t.id = ct.tracks_id 
where ct.tracks_id is null

--исполнителя(-ей), написавшего самый короткий по продолжительности трек
select m."name" as musicians, t.duration as min_duration
from musicians m 
join albums_musicians am on m.id = am.musicians_id 
join albums a on am.albums_id = a.id 
join tracks t on t.id_albums = a.id 
group  by musicians, min_duration
having t.duration in 
	(select min(t2.duration) from tracks t2)

--название альбомов, содержащих наименьшее количество треков
select a."name" as albums, count(t.id) as min_amount
from albums a 
join tracks t on t.id_albums = a.id
where a.id in 
	(select t2.id_albums 
	from tracks t2
	group by t2.id_albums
	having count(t2.id) in 
		(select count(t3.id) 
		from tracks t3
		group by t3.id_albums
		order by count(t3.id)
		limit 1)
	)
group by albums