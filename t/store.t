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

$$hash{'foo'} = 10;
$$hash{'none'} = 'whatsoever';
$$hash{'kiss'} = 'my';
$$hash{'code'} = 'haha';

print "not " unless ($object = tied %{$hash}) && exists $$object{'hashes'} &&
    ref $$object{'hashes'} eq "ARRAY";
print "ok 3\n";

print "not " unless @{$$object{'hashes'}} == 2 &&
    keys %{$$object{'hashes'}[0]} == 1 &&
    keys %{$$object{'hashes'}[1]} == 2 &&
    keys %{$$object{'remainder'}} == 4 &&
    $$object{'hashes'}[0]{'foo'} == 10 &&
    $$object{'hashes'}[1]{'none'} eq 'whatsoever' &&
    $$object{'hashes'}[1]{'your'} eq 'business' &&
    $$object{'remainder'}{'key'} eq 'value' &&
    $$object{'remainder'}{'foo'} eq 'baz' &&
    $$object{'remainder'}{'kiss'} eq 'my' &&
    $$object{'remainder'}{'code'} eq 'haha';
print "ok 4\n";

$$hash{'hmm...'} = 'interesting';
$$hash{'good'} = 'stuff';
$$hash{'foo'} = 'foo';
$$hash{'code'} = 'warrior';
$$hash{'key'} = 'to the door';
$$hash{'your'} = 'hash';

print "not " unless @{$$object{'hashes'}} == 2 &&
    keys %{$$object{'hashes'}[0]} == 1 &&
    keys %{$$object{'hashes'}[1]} == 2 &&
    keys %{$$object{'remainder'}} == 6 &&
    $$object{'hashes'}[0]{'foo'} eq 'foo' &&
    $$object{'hashes'}[1]{'none'} eq 'whatsoever' &&
    $$object{'hashes'}[1]{'your'} eq 'hash' &&
    $$object{'remainder'}{'key'} eq 'to the door' &&
    $$object{'remainder'}{'foo'} eq 'baz' &&
    $$object{'remainder'}{'kiss'} eq 'my' &&
    $$object{'remainder'}{'code'} eq 'warrior' &&
    $$object{'remainder'}{'hmm...'} eq 'interesting' &&
    $$object{'remainder'}{'good'} eq 'stuff';
print "ok 5\n";
