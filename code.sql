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
select
    json_extract_path_text(a1.city, 'en') as city1,
    json_extract_path_text(a2.city, 'en') as city2,
    extract(EPOCH from (cast(f.scheduled_arrival as timestamp) - cast(f.scheduled_departure as timestamp))) as time_dist
from airports_data a1, flights f, airports_data a2
where f.arrival_airport = a1.airport_code and f.departure_airport = a2.airport_code
group by city1, city2, time_dist
having json_extract_path_text(a1.city, 'en') = 'Moscow' and json_extract_path_text(a2.city, 'en') = 'Petropavlovsk'
