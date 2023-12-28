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

