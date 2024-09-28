import 'package:flutter/material.dart';

class CompactOpeningHoursWidget extends StatelessWidget {
  final List<String> weekdayText;
  final List<String>? openingTimes;

  const CompactOpeningHoursWidget({
    Key? key,
    required this.weekdayText,
    this.openingTimes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: weekdayText.map((day) {
          final index = weekdayText.indexOf(day);
          final hours = openingTimes != null && openingTimes!.length > index
              ? openingTimes![index]
              : 'Closed';

          final isOpen = hours != 'Closed';
          return Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: isOpen ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    Text(
                      day.substring(0, 3),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOpen ? Colors.black : Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      isOpen ? hours : 'Closed',
                      style: TextStyle(
                        color: isOpen ? Colors.black : Colors.grey,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
