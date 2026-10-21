# NS-2: HTTP, FTP and SMTP Traffic

set ns [new Simulator]

# Trace and NAM files
set tr [open trace1.tr w]
set nam [open opnam.nam w]
$ns trace-all $tr
$ns namtrace-all $nam

# Output files
set ft1 [open Sender1_throughput.tr w]
set ft2 [open Sender2_throughput.tr w]
set ft3 [open Sender3_throughput.tr w]
set ft4 [open Total_throughput.tr w]

set fb1 [open Bandwidth1.tr w]
set fb2 [open Bandwidth2.tr w]
set fb3 [open Bandwidth3.tr w]
set fb4 [open TotalBandwidth.tr w]


# Record throughput and bandwidth
proc record {} {
    global ns null1 null2 null3
    global ft1 ft2 ft3 ft4 fb1 fb2 fb3 fb4

    set interval 0.1
    set now [$ns now]

    set b1 [$null1 set bytes_]
    set b2 [$null2 set bytes_]
    set b3 [$null3 set bytes_]
    set total [expr {$b1+$b2+$b3}]

    # Throughput in Mbps
    set t1 [expr {$b1*8.0/$interval/1000000}]
    set t2 [expr {$b2*8.0/$interval/1000000}]
    set t3 [expr {$b3*8.0/$interval/1000000}]
    set tt [expr {$total*8.0/$interval/1000000}]

    puts $ft1 "$now $t1"
    puts $ft2 "$now $t2"
    puts $ft3 "$now $t3"
    puts $ft4 "$now $tt"

    # Bandwidth in bits/sec
    puts $fb1 "$now [expr {$b1*8.0/$interval}]"
    puts $fb2 "$now [expr {$b2*8.0/$interval}]"
    puts $fb3 "$now [expr {$b3*8.0/$interval}]"
    puts $fb4 "$now [expr {$total*8.0/$interval}]"

    $null1 set bytes_ 0
    $null2 set bytes_ 0
    $null3 set bytes_ 0

    $ns at [expr {$now+$interval}] "record"
}


# Create 10 nodes
for {set i 0} {$i < 10} {incr i} {
    set n($i) [$ns node]
}


# Network topology
$ns duplex-link $n(0) $n(1) 1Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 1Mb 10ms DropTail
$ns duplex-link $n(2) $n(7) 2Mb 10ms RED

$ns duplex-link $n(0) $n(3) 1.5Mb 10ms RED
$ns duplex-link $n(3) $n(5) 1Mb 10ms DropTail
$ns duplex-link $n(5) $n(6) 1Mb 10ms RED
$ns duplex-link $n(6) $n(4) 1Mb 10ms DropTail
$ns duplex-link $n(4) $n(7) 1Mb 10ms RED

$ns duplex-link $n(7) $n(8) 2Mb 10ms DropTail
$ns duplex-link $n(8) $n(9) 2Mb 10ms RED


# NAM layout
$ns duplex-link-op $n(0) $n(1) orient right-up
$ns duplex-link-op $n(1) $n(2) orient right
$ns duplex-link-op $n(2) $n(7) orient right-down
$ns duplex-link-op $n(0) $n(3) orient right-down
$ns duplex-link-op $n(3) $n(5) orient right-down
$ns duplex-link-op $n(5) $n(6) orient right
$ns duplex-link-op $n(6) $n(4) orient left-up
$ns duplex-link-op $n(4) $n(7) orient right-up
$ns duplex-link-op $n(7) $n(8) orient right-up
$ns duplex-link-op $n(8) $n(9) orient right-down


# FTP: Node 0 -> Node 8
set tcp1 [new Agent/TCP]
set null1 [new Agent/TCPSink]
$ns attach-agent $n(0) $tcp1
$ns attach-agent $n(8) $null1
$ns connect $tcp1 $null1

set ftp [new Application/FTP]
$ftp attach-agent $tcp1
$ns at 1.0 "$ftp start"
$ns at 3.2 "$ftp stop"


# SMTP-like: Node 3 -> Node 6
set tcp2 [new Agent/TCP]
set null2 [new Agent/TCPSink]
$ns attach-agent $n(3) $tcp2
$ns attach-agent $n(6) $null2
$ns connect $tcp2 $null2

set smtp [new Application/Traffic/Exponential]
$smtp set packetSize_ 512
$smtp set burst_time_ 0.5
$smtp set idle_time_ 0.5
$smtp set rate_ 500Kb
$smtp attach-agent $tcp2
$ns at 2.0 "$smtp start"
$ns at 3.8 "$smtp stop"


# HTTP-like: Node 0 -> Node 7
set tcp3 [new Agent/TCP]
set null3 [new Agent/TCPSink]
$ns attach-agent $n(0) $tcp3
$ns attach-agent $n(7) $null3
$ns connect $tcp3 $null3

set http [new Application/Traffic/Exponential]
$http set packetSize_ 512
$http set burst_time_ 0.5
$http set idle_time_ 0.5
$http set rate_ 500Kb
$http attach-agent $tcp3
$ns at 0.2 "$http start"
$ns at 3.2 "$http stop"


# Start recording
$ns at 0.5 "record"


# Finish
proc finish {} {
    global ns tr nam
    global ft1 ft2 ft3 ft4 fb1 fb2 fb3 fb4

    $ns flush-trace

    foreach f "$tr $nam $ft1 $ft2 $ft3 $ft4 $fb1 $fb2 $fb3 $fb4" {
        close $f
    }

    exec nam opnam.nam &
    exec xgraph Sender1_throughput.tr Sender2_throughput.tr \
        Sender3_throughput.tr Total_throughput.tr &

    exec xgraph Bandwidth1.tr Bandwidth2.tr \
        Bandwidth3.tr TotalBandwidth.tr &

    exit 0
}

$ns at 5.0 "finish"

puts "Starting NS-2 simulation..."
$ns run
