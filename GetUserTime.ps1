function Get-UserTime {
    $dateHour = Get-date -UFormat '%H'
    if ($dateHour -le 12) {
        "Good Morning"
    }
    ELSeIF ($dateHour -gt 12 -AND $dateHour -le 18) {
        "Good Afternoon"
    }
    ELSE {
        "Good Evening"
    }
}
Get-UserTime