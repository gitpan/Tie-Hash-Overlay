BEGIN { $| = 1; print "1..8\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Hash::Overlay;
$loaded = 1;
print "ok 1\n";

$hash = new Tie::Hash::Overlay;
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 2\n";

$hashlist = [ { 'foo' => 'bar' }, { 'none' => 'of', 'your' => 'business' } ];

undef $hash;

$hash = new Tie::Hash::Overlay $hashlist;
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 3\n";

print "not " unless ($object = tied %{$hash}) && exists $$object{'hashes'} &&
    ref $$object{'hashes'} eq "ARRAY";
print "ok 4\n";

print "not " unless @{$$object{'hashes'}} == 2 &&
    $$object{'hashes'}[0] == $$hashlist[0] &&
    $$object{'hashes'}[1] == $$hashlist[1] &&
    $$object{'hashes'}[0] != $$hashlist[1];
print "ok 5\n";

undef $hash;
undef $object;

$remainder = { 'key' => 'value', 'foo' => 'bar' };

$hash = new Tie::Hash::Overlay $hashlist, $remainder;
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 6\n";

print "not " unless ($object = tied %{$hash}) && exists $$object{'hashes'} &&
    ref $$object{'hashes'} eq "ARRAY" && exists $$object{'remainder'} &&
    ref $$object{'remainder'} eq "HASH";
print "ok 7\n";

print "not " unless @{$$object{'hashes'}} == 2 &&
    scalar keys %{$$object{'remainder'}} == 2 &&
    $$object{'remainder'} == $remainder;
print "ok 8\n";
