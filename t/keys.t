BEGIN { $| = 1; print "1..6\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Hash::Overlay;
$loaded = 1;
print "ok 1\n";

$hashlist = [ { 'foo' => 'bar' }, { 'none' => 'of', 'your' => 'business' } ];
$remainder = { 'key' => 'value', 'foo' => 'baz' };

$hash = new Tie::Hash::Overlay $hashlist, $remainder;
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 2\n";

@keys = keys %{$hash};

print "not " unless @keys eq 4;
print "ok 3\n";

@sortedkeys = ('foo', 'none', 'your', 'key');

if($keys[1] eq 'your') {
    $key = $keys[1];
    $keys[1] = $keys[2];
    $keys[2] = $key;
}

$failed = 0;

for($i = 0; $i < @keys && $i < @sortedkeys; $i++) {
    $failed++ unless $keys[$i] eq $sortedkeys[$i];
}
print "not " if $failed;
print "ok 4\n";

@keys = keys %{$hash};

print "not " unless @keys eq 4;
print "ok 5\n";

if($keys[1] eq 'your') {
    $key = $keys[1];
    $keys[1] = $keys[2];
    $keys[2] = $key;
}

$failed = 0;

for($i = 0; $i < @keys && $i < @sortedkeys; $i++) {
    $failed++ unless $keys[$i] eq $sortedkeys[$i];
}
print "not " if $failed;
print "ok 6\n";
