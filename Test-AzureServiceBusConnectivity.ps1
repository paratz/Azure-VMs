$urls = "g0-prod-bl3-012-sb.servicebus.windows.net", "g1-prod-bl3-012-sb.servicebus.windows.net", "g2-prod-bl3-012-sb.servicebus.windows.net", "g3-prod-bl3-012-sb.servicebus.windows.net", "g4-prod-bl3-012-sb.servicebus.windows.net", "g5-prod-bl3-012-sb.servicebus.windows.net", "g6-prod-bl3-012-sb.servicebus.windows.net", "g7-prod-bl3-012-sb.servicebus.windows.net", "g8-prod-bl3-012-sb.servicebus.windows.net", "g9-prod-bl3-012-sb.servicebus.windows.net", "g10-prod-bl3-012-sb.servicebus.windows.net", "g11-prod-bl3-012-sb.servicebus.windows.net", "g12-prod-bl3-012-sb.servicebus.windows.net", "g13-prod-bl3-012-sb.servicebus.windows.net", "g14-prod-bl3-012-sb.servicebus.windows.net", "g15-prod-bl3-012-sb.servicebus.windows.net", "g16-prod-bl3-012-sb.servicebus.windows.net", "g17-prod-bl3-012-sb.servicebus.windows.net", "g18-prod-bl3-012-sb.servicebus.windows.net", "g19-prod-bl3-012-sb.servicebus.windows.net", "g20-prod-bl3-012-sb.servicebus.windows.net", "g21-prod-bl3-012-sb.servicebus.windows.net", "g22-prod-bl3-012-sb.servicebus.windows.net", "g23-prod-bl3-012-sb.servicebus.windows.net", "g24-prod-bl3-012-sb.servicebus.windows.net", "g25-prod-bl3-012-sb.servicebus.windows.net", "g26-prod-bl3-012-sb.servicebus.windows.net", "g27-prod-bl3-012-sb.servicebus.windows.net", "g28-prod-bl3-012-sb.servicebus.windows.net", "g29-prod-bl3-012-sb.servicebus.windows.net", "g30-prod-bl3-012-sb.servicebus.windows.net", "g31-prod-bl3-012-sb.servicebus.windows.net"
$ports = 443, 5671, 5672, 9350,	9351, 9352, 9353, 9354

foreach ($url in $urls ) {
    foreach ($port in $ports) {

    Test-NetConnection -ComputerName $url -Port $port | Export-Csv -Path Results.csv -Append
    
    }
}

