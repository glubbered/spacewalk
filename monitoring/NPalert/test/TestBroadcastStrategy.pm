package test::TestBroadcastStrategy;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::BroadcastStrategy;
use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::ContactGroup;
use NOCpulse::Notif::Alert;
use NOCpulse::Notif::Escalator;

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__,9);

my $MODULE = 'NOCpulse::Notif::BroadcastStrategy';

my $MY_INTERNAL_EMAIL = 'kja@redhat.com';
my $MY_EXTERNAL_EMAIL = 'nerkren@yahoo.com';
my $NOWHERE_EMAIL     = 'nobody@nocpulse.com';


######################
sub test_constructor {
######################
  my $self = shift;
  my $obj = $MODULE->new();

  # Make sure creation succeeded
  $self->assert(defined($obj), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$obj");
        
}

############
sub set_up {
############
  my $self = shift;
  # This method is called before each test.

  $self->{'internal_dest'}=NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_INTERNAL_EMAIL);
  $self->{'external_dest'}=NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_EXTERNAL_EMAIL);
  $self->{'nowhere_dest'}=NOCpulse::Notif::EmailContactMethod->new( 'email' => $NOWHERE_EMAIL);

  $self->{'group'}=NOCpulse::Notif::ContactGroup->new();

  $self->{'group'}->add_destination($self->{'internal_dest'});
  $self->{'group'}->add_destination($self->{'external_dest'});
  $self->{'group'}->add_destination($self->{'nowhere_dest'});

  $self->{'alert'}    = NOCpulse::Notif::Alert->new( 'message'   => 'The rain in Spain stays mainly on the plain',
                                    'groupName' => 'Karen_Group',
                                    'clusterId' => 29,
                                    'state'     => 'WARNING',
                                    'groupId'   => 11991,
                                    'probeId'   => 3000,
                                    'customerId'=> 30 );

  $self->{'strategy'}=$MODULE->new_for_group($self->{'group'},$self->{'alert'});
  $self->{'strategy'}->ack_wait(5);

  $self->{'escalator'}=NOCpulse::Notif::Escalator->new();
}

# INSERT INTERESTING TESTS HERE

########################
sub test_new_for_group {
########################
  my $self=shift;
  
  my $alert=$self->{'alert'};
  my $strategy=$MODULE->new_for_group($self->{'group'},$alert);
  my @list=map { $_->destination } @{$strategy->sends};
  my $item=shift(@list);
  $self->assert($item->email eq $MY_INTERNAL_EMAIL,"internal email (1)");
  $item=shift(@list);
  $self->assert($item->email eq $MY_EXTERNAL_EMAIL,"external email (1)");
  $item=shift(@list);
  $self->assert($item->email eq $NOWHERE_EMAIL,"nowhere email (1)");
} 

#########################
sub test_new_for_method {
#########################
  my $self=shift;

  my $alert=$self->{'alert'};
  my $strategy=$MODULE->new_for_method($self->{'internal_dest'},$alert);

  # Make sure creation succeeded
  $self->assert(defined($strategy), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$strategy");
        
  my $send=$strategy->sends_pop;

  # Make sure send creation succeeded
  $self->assert(defined($strategy), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  my $SEND_MODULE="NOCpulse::Notif::Send";
  $self->assert(qr/$SEND_MODULE/, "$send");
  $Log->dump(9,"send: ",$send,"\n");
}

#####################
sub test_send_named {
#####################
  my $self = shift;

  my $alert=$self->{'alert'};
  my $strategy=$MODULE->new_for_method($self->{'internal_dest'},$alert);

  my @sends = $strategy->sends;

  my $count = 0;
  foreach my $send (@sends) {
    $send->send_id(sprintf("%6.6d", $count));
    $count++;
  }

  $count = 0;
  foreach my $send (@sends) {
    my $name = sprintf("%6.6d", $count);
    my $result = $strategy->send_named($name);
    $self->assert($result, "test_send_named result exists $count");
    print $send->send_id, " == ", $result->send_id, "\n";
    $self->assert($result == $send, "test_send_named $count");
  }
}

##############
sub test_ack {
##############
  my $self=shift;
  my $alert  = $self->{'alert'};
  my $strategy  = $self->{'strategy'};
  my $esc = $self->{'escalator'};
  my @sends = @{$strategy->sends};
  my $send = $sends[0];

  my $filename="/tmp/TestEscalateStrategy.test_next_sends.$$.tmp";
  $alert->to_file($filename);
  my $alert_id=$esc->register_alert($filename);
  $send->alert_id($alert_id);
  $esc->start_sends($send);
  my $send_id = $send->send_id;
  $esc->_work_queue_clear();
  $send->acknowledgement('nak');

  $strategy->ack($send,$alert,$esc);
  $self->assert(!defined($esc->_sends($send_id)),"test_ack");
}


######################
sub test_printString {
######################
  my $self=shift;
  my $strategy = $self->{'strategy'};
  $strategy->ack_method('AllAck');
  
  my $string = $strategy->printString;
  $self->assert($string =~ /Broadcast/,"Broadcast");
  $self->assert($string =~ /AllAck/,"AllAck");
}

1;

