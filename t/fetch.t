BEGIN { $| = 1; print "1..3\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Hash::Overlay;
$loaded = 1;
print "ok 1\n";

$hashlist = [ { 'foo' => 'bar' }, { 'none' => 'of', 'your' => 'business' } ];
$remainder = { 'key' => 'value', 'foo' => 'baz' };

$hash = new Tie::Hash::Overlay $hashlist, $remainder;
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 2\n";

print "not " unless $$hash{'foo'} eq 'bar' && $$hash{'foo'} eq 'bar' &&
    $$hash{'none'} eq 'of' && $$hash{'your'} eq 'business' &&
    $$hash{'key'} eq 'value';
print "ok 3\n";