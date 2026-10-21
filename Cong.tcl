```tcl
# TCP Congestion Control: Vegas, Reno, NewReno, SACK1, Tahoe

set ns [new Simulator]

# Trace files
set tf [open TCPcc.tr w]
set nf [open TCPcc.nam w]
$ns trace-all $tf
$ns namtrace-all $nf

# Throughput files
set ft1 [open Vegas_Throughput.tr w]
set ft2 [open Reno_Throughput.tr w]
set ft3 [open NewReno_Throughput.tr w]
set ft4 [open SACK1_Throughput.tr w]
set ft5 [open Tahoe_Throughput.tr w]

# Bandwidth files
set fb1 [open Vegas_Bandwidth.tr w]
set fb2 [open Reno_Bandwidth.tr w]
set fb3 [open NewReno_Bandwidth.tr w]
set fb4 [open SACK1_Bandwidth.tr w]
set fb5 [open Tahoe_Bandwidth.tr w]


# Record throughput and bandwidth
proc record {} {
    global ns null1 null2 null3 null4 null5
    global ft1 ft2 ft3 ft4 ft5
    global fb1 fb2 fb3 fb4 fb5

    set interval 0.1
    set now [$ns now]

    set b1 [$null1 set bytes_]
    set b2 [$null2 set bytes_]
    set b3 [$null3 set bytes_]
    set b4 [$null4 set bytes_]
    set b5 [$null5 set bytes_]

    # Throughput in Mbps
    puts $ft1 "$now [expr {$b1*8.0/$interval/1000000}]"
    puts $ft2 "$now [expr {$b2*8.0/$interval/1000000}]"
    puts $ft3 "$now [expr {$b3*8.0/$interval/1000000}]"
    puts $ft4 "$now [expr {$b4*8.0/$interval/1000000}]"
    puts $ft5 "$now [expr {$b5*8.0/$interval/1000000}]"

    # Bandwidth in bits/sec
    puts $fb1 "$now [expr {$b1*8.0/$interval}]"
    puts $fb2 "$now [expr {$b2*8.0/$interval}]"
    puts $fb3 "$now [expr {$b3*8.0/$interval}]"
    puts $fb4 "$now [expr {$b4*8.0/$interval}]"
    puts $fb5 "$now [expr {$b5*8.0/$interval}]"

    # Reset counters
    foreach x {$null1 $null2 $null3 $null4 $null5} {
        $x set bytes_ 0
    }

    $ns at [expr {$now+$interval}] "record"
}


# Create 6 nodes
for {set i 0} {$i < 6} {incr i} {
    set n($i) [$ns node]
}


# Network topology
$ns duplex-link $n(0) $n(1) 10Kb 10ms DropTail
$ns duplex-link $n(1) $n(2) 50Kb 10ms DropTail
$ns duplex-link $n(2) $n(5) 200Kb 10ms RED

$ns duplex-link $n(0) $n(3) 100Kb 10ms RED
$ns duplex-link $n(3) $n(4) 70Kb 10ms DropTail
$ns duplex-link $n(4) $n(5) 100Kb 10ms DropTail


# NAM orientation
$ns duplex-link-op $n(0) $n(1) orient right
$ns duplex-link-op $n(1) $n(2) orient right-down
$ns duplex-link-op $n(2) $n(5) orient left-down
$ns duplex-link-op $n(0) $n(3) orient left-down
$ns duplex-link-op $n(3) $n(4) orient right-down
$ns duplex-link-op $n(4) $n(5) orient right


# Function to create TCP traffic
proc tcp_traffic {source destination type nullName appName} {
    global ns

    upvar $nullName null
    upvar $appName app

    set tcp [new $type]
    set null [new Agent/TCPSink]

    $ns attach-agent $source $tcp
    $ns attach-agent $destination $null
    $ns connect $tcp $null

    set app [new Application/Traffic/Exponential]
    $app set packetSize_ 512
    $app set burst_time_ 0.5
    $app set idle_time_ 0.5
    $app set rate_ 500Kb
    $app attach-agent $tcp
}


# Create five TCP flows
tcp_traffic $n(0) $n(5) Agent/TCP/Vegas null1 app1
tcp_traffic $n(1) $n(5) Agent/TCP/Reno null2 app2
tcp_traffic $n(2) $n(5) Agent/TCP/Newreno null3 app3
tcp_traffic $n(3) $n(4) Agent/TCP/Sack1 null4 app4
tcp_traffic $n(3) $n(5) Agent/TCP null5 app5


# Start and stop traffic
$ns at 0.5 "record"

$ns at 0.2 "$app1 start"
$ns at 3.2 "$app1 stop"

$ns at 3.2 "$app2 start"
$ns at 6.2 "$app2 stop"

$ns at 6.2 "$app3 start"
$ns at 9.2 "$app3 stop"

$ns at 9.2 "$app4 start"
$ns at 12.2 "$app4 stop"

$ns at 12.2 "$app5 start"
$ns at 15.2 "$app5 stop"


# Finish
proc finish {} {
    global ns tf nf
    global ft1 ft2 ft3 ft4 ft5
    global fb1 fb2 fb3 fb4 fb5

    $ns flush-trace

    foreach f "$tf $nf $ft1 $ft2 $ft3 $ft4 $ft5 $fb1 $fb2 $fb3 $fb4 $fb5" {
        close $f
    }

    exec nam TCPcc.nam &

    exec xgraph Vegas_Throughput.tr Reno_Throughput.tr \
        NewReno_Throughput.tr SACK1_Throughput.tr Tahoe_Throughput.tr &

    exec xgraph Vegas_Bandwidth.tr Reno_Bandwidth.tr \
        NewReno_Bandwidth.tr SACK1_Bandwidth.tr Tahoe_Bandwidth.tr &

    exit 0
}

$ns at 16.0 "finish"

puts "Starting TCP congestion control simulation..."
$ns run
```
