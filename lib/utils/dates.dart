/// [d] without the time of day: midnight at the start of that day.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Whole days between two dates. Done in UTC, because in local time a
/// daylight saving change makes some days 23 hours long.
int calendarDaysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
