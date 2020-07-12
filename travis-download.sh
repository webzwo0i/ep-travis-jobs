#assumes you have installed gem travis, gem install --user travis

travis=~/.gem/ruby/2.5.0/bin/travis
repo=ether/etherpad-lite

#get all build number
echo "getting build history"
$travis history --repo ether/etherpad-lite --limit 20000 >build-history

echo "download builds"
#only download new builds
for buildid in $(((ls -1 builds/) && (awk '{gsub(/#/,"");print $1}' build-history))|sort|uniq -u);do
  $travis show --repo $repo $buildid >builds/$buildid
done

echo "download jobs"
#only download new jobs
for jobid in $(((ls -1 jobs/) && (grep -Pr "(?<=Job #)\d+\.\d+" builds -oh))|sort|uniq -u);do
  $travis logs --repo $repo $jobid > jobs/$jobid
done
