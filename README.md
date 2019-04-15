Some UIKit components don't support Dynamic Type. This repo contains a
(partial) replacement for UIStepper and UIDatePicker that attempts to make
itself or any containing labels bigger or smaller, when the user changes the
iOS font size setting.

Missing features:
- When the DatePicker is in DateTimeMode, the sequence of month-day is fixed,
  which should actually be based on locale
- It may be possible to select a non-existing time (for instance an hour that's
  not existing due to daylight savings time)

Todo's in the code:
- Remove "as NSCalendar"

