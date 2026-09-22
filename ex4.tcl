# Create Simulator object
set ns [new Simulator]

# Trace and NAM files
set tracefile [open tester.tr w]
$ns trace-all $tracefile

set namfile [open tester.nam w]
$ns namtrace-all $namfile

# Define finish procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam tester.nam &
    exit 0
}

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

# Create duplex links between nodes
$ns duplex-link $n0 $n1 1Mb 10ms FQ
$ns duplex-link $n1 $n2 7Mb 13ms FQ
$ns duplex-link $n1 $n3 5Mb 10ms FQ
$ns duplex-link $n0 $n2 3Mb 10ms FQ
$ns duplex-link $n2 $n4 2Mb 10ms FQ
$ns duplex-link $n2 $n5 11Mb 10ms FQ
$ns duplex-link $n5 $n1 12Mb 10ms FQ
$ns duplex-link $n4 $n1 18Mb 10ms FQ

# Set queue limits
$ns queue-limit $n0 $n1 20
$ns queue-limit $n1 $n2 20
$ns queue-limit $n1 $n3 20
$ns queue-limit $n0 $n2 20
$ns queue-limit $n2 $n4 20
$ns queue-limit $n2 $n5 20
$ns queue-limit $n5 $n1 20
$ns queue-limit $n4 $n1 20

# Create UDP agent and attach to node 0
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

# Create Null agent and attach to node 4
set null0 [new Agent/Null]
$ns attach-agent $n4 $null0

# Connect UDP and Null agents
$ns connect $udp0 $null0

# Create CBR application and attach to UDP
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.01
$cbr0 attach-agent $udp0

# Schedule events
$ns at 0.5 "$cbr0 start"
$ns at 1.5 "$cbr0 stop"
$ns at 2.5 "finish"

puts "Simulation Started..."
$ns run
