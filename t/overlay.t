BEGIN { $| = 1; print "1..5\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Hash::Overlay qw(&overlay);
$loaded = 1;
print "ok 1\n";

$hash = new Tie::Hash::Overlay;
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 2\n";

$hashlist = [ { 'foo' => 'bar' }, { 'none' => 'of', 'your' => 'business' } ];
$remainder = { 'key' => 'value', 'foo' => 'baz' };

overlay $hash, $$hashlist[0];

print "not " unless ($object = tied %{$hash}) && exists $$object{'hashes'} &&
    ref $$object{'hashes'} eq "ARRAY";
print "ok 3\n";

print "not " unless @{$$object{'hashes'}} == 1 &&
    $$object{'hashes'}[0] == $$hashlist[0];
print "ok 4\n";

overlay $hash, $$hashlist[1], $remainder;

print "not " unless @{$$object{'hashes'}} == 2 &&
    $$object{'hashes'}[0] == $$hashlist[0] &&
    $$object{'hashes'}[1] == $$hashlist[1] &&
    $$object{'hashes'}[0] != $$hashlist[1] &&
    keys %{$$object{'hashes'}[1]} == 2 &&
    $$object{'remainder'} == $remainder;
print "ok 5\n";
