BEGIN { $| = 1; print "1..5\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Hash::Overlay;
$loaded = 1;
print "ok 1\n";

$hashlist = [ { 'foo' => 'bar' }, { 'none' => 'of', 'your' => 'business' } ];
$remainder = { 'key' => 'value', 'foo' => 'baz' };

$hash = new Tie::Hash::Overlay $hashlist, $remainder;
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 2\n";

print "not " unless ($object = tied %{$hash}) && exists $$object{'hashes'} &&
    ref $$object{'hashes'} eq "ARRAY";
print "ok 3\n";

print "not " unless @{$$object{'hashes'}} == 2 &&
    keys %{$$object{'hashes'}[0]} == 1 &&
    keys %{$$object{'hashes'}[1]} == 2 &&
    keys %{$$object{'remainder'}} == 2;
print "ok 4\n";

%{$hash} = ();

print "not " unless @{$$object{'hashes'}} == 2 &&
    keys %{$$object{'hashes'}[0]} == 0 &&
    keys %{$$object{'hashes'}[1]} == 0 &&
    keys %{$$object{'remainder'}} == 0;
print "ok 5\n";
