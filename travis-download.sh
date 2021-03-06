#assumes you have installed gem travis, gem install --user travis

travis=~/.gem/ruby/2.5.0/bin/travis
repo=ether/etherpad-lite

#TODO: find out if it is possible to only download new builds
#get all build number
echo "getting build history"
$travis history --com --repo ether/etherpad-lite --limit 20000 >build-history

echo "download builds"
#only download new builds
for buildid in $(((ls -1 builds/) && (awk '{gsub(/#/,"");print $1}' build-history|sort|uniq))|sort|uniq -u);do
  $travis show --com --repo $repo $buildid >builds/$buildid
done

echo "download jobs"
#only download new jobs
for jobid in $(((ls -1 jobs/) && (grep -Pr "(?<=^Job #)\d+\.\d+|(?<=^#)\d+\.\d+" builds -oh))|sort|uniq -u);do
  $travis logs --com --repo $repo $jobid > jobs/$jobid
done
