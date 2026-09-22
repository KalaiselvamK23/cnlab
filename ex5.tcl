# Initialize variables
set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(ifqlen)     50
set val(nn)         6
set val(rp)         AODV
set val(x)          500
set val(y)          500

# Create Simulator object
set ns [new Simulator]

# Create Tracing and Animation files
set tracefile [open wireless.tr w]
$ns trace-all $tracefile

set namfile [open wireless.nam w]
$ns namtrace-all-wireless $namfile $val(x) $val(y)

# Create Topography
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

# GOD Creation
create-god $val(nn)

# Channel initialization
set channel1 [new $val(chan)]

# Configure the Node parameters
$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -topoInstance $topo \
                -agentTrace ON \
                -macTrace ON \
                -routerTrace ON \
                -movementTrace ON \
                -channel $channel1

# Create Nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

# Turn off random motion to maintain layout control
$n0 random-motion 0
$n1 random-motion 0
$n2 random-motion 0
$n3 random-motion 0
$n4 random-motion 0
$n5 random-motion 0

$ns initial_node_pos $n0 20
$ns initial_node_pos $n1 20
$ns initial_node_pos $n2 20
$ns initial_node_pos $n3 20
$ns initial_node_pos $n4 20
$ns initial_node_pos $n5 50

# Topology Coordinates configured to match diagram layout visual positions
$n0 set X_ 100.0
$n0 set Y_ 400.0
$n0 set Z_ 0.0

$n1 set X_ 50.0
$n1 set Y_ 150.0
$n1 set Z_ 0.0

$n5 set X_ 150.0
$n5 set Y_ 100.0
$n5 set Z_ 0.0

$n2 set X_ 250.0
$n2 set Y_ 180.0
$n2 set Z_ 0.0

$n3 set X_ 380.0
$n3 set Y_ 250.0
$n3 set Z_ 0.0

$n4 set X_ 450.0
$n4 set Y_ 380.0
$n4 set Z_ 0.0

# Node Mobility Destinations (as nodes move during runtime)
$ns at 1.0 "$n1 setdest 490.0 340.0 25.0"
$ns at 1.0 "$n4 setdest 300.0 130.0 5.0"
$ns at 1.0 "$n5 setdest 190.0 440.0 15.0"
$ns at 20.0 "$n5 setdest 100.0 200.0 30.0"

# Setup TCP Traffic (Link between Node 0 and Node 5)
set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]
$ns attach-agent $n0 $tcp
$ns attach-agent $n5 $sink
$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 1.0 "$ftp start"

# Setup UDP Traffic (Link between Node 2 and Node 3)
set udp [new Agent/UDP]
set null [new Agent/Null]
$ns attach-agent $n2 $udp
$ns attach-agent $n3 $null
$ns connect $udp $null

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns at 1.0 "$cbr start"

# Simulation Stop Strategy
$ns at 30.0 "finish"

proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exit 0
}

puts "Starting Simulation"
$ns run
