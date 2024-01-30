-- github.com/tahadostifam

-- Section1
select aircraft_code, fare_conditions, count(distinct seat_no) AS count
FROM public.airports_data
INNER JOIN seats ON aircraft_code=aircraft_code
GROUP BY aircraft_code, fare_conditions
ORDER BY aircraft_code,fare_conditions desc, count;

-- Section2
select day, count(*) from (
	select TO_CHAR(cast(flights.scheduled_departure as DATE), 'Day') as day
	from flights left join ticket_flights on flights.flight_id=ticket_flights.flight_id
	where flights.status='Cancelled'
)
group by day
order by count desc;

-- Section3
select
	json_extract_path_text(airport_name, 'en') as airport,
	model as aircraft_model,
	count(flight_id) as count,
	rank() over(
		partition by json_extract_path_text(airport_name, 'en')
		order by count(flight_id) desc
	) as rank
from (
	select airport_name, model, public.flights.aircraft_code, ticket_flights.flight_id from public.flights
	left join public.aircrafts_data on public.flights.aircraft_code=public.aircrafts_data.aircraft_code
	left join public.airports_data
		on public.flights.arrival_airport=public.airports_data.airport_code
		or public.flights.departure_airport=public.airports_data.airport_code
	left join public.ticket_flights on public.ticket_flights.flight_id=public.flights.flight_id
	where public.flights.status='Arrived'
)
group by airport, model
having count(flight_id) > 0
order by airport, rank, model;

-- Section4
select city1, city2, extract(hour from time_diff) * 60 + extract(minutes from time_diff) from (
    SELECT json_extract_path_text(a1.city, 'en') AS city1,
           json_extract_path_text(a2.city, 'en') AS city2,
           avg(CAST(f.scheduled_arrival AS TIMESTAMP) - CAST(f.scheduled_departure AS TIMESTAMP)) AS time_diff
    FROM airports_data a1
             JOIN flights f ON f.arrival_airport = a1.airport_code
             JOIN airports_data a2 ON f.departure_airport = a2.airport_code
    WHERE json_extract_path_text(a1.city, 'en') = 'Moscow'
      AND json_extract_path_text(a2.city, 'en') = 'Petropavlovsk'
    GROUP BY city1, city2
) as time difference_of_cities
