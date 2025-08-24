// extension DatetimeExtensions on DateTime {
//   bool isLegalAge(DateTime firstDate, DateTime comparisonDate){
//     return comparisonDate.difference(firstDate) <= Duration(days: 6570);
//   }
// }

extension DateTimeExtensions on DateTime {
  bool isLegalAge({int minimumAge = 18}) {
    final today = DateTime.now();
    final years = today.year - year;
    final hadBirthday = (today.month > month) ||
        (today.month == month && today.day >= day);
    return hadBirthday ? years >= minimumAge : years - 1 >= minimumAge;
  }
}