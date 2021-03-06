directors = load 'director-and-title.txt'
as (director: chararray, title:chararray, year: chararray);

actors = load 'title-and-actor.txt'
as (title: chararray, actor:chararray, year: chararray, role: chararray);

result = foreach (cogroup directors by director inner, actors by actor inner)
	generate group, directors.title, actors.title;

dump result;
