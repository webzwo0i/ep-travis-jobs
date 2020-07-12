#assumes you have installed gem travis, gem install --user travis

travis=~/.gem/ruby/2.5.0/bin/travis
repo=ether/etherpad-lite

#for buildid in $(awk '{print $1}' build-history |cut -d# -f2|sort|uniq);do ~/.gem/ruby/2.5.0/bin/travis show $buildid >~/travis-jobs/dl/$buildid;done
#for jobid in $((grep -oh '#[0-9]*\.[0-9]' ../travis-jobs/dl/*|sort|uniq|cut -d# -f2|sort|uniq && (ls ~/travis-jobs/detailed/|sed -e 's# #\n#g'))|sort|uniq -c|grep -v " 2 "|awk '{print $NF}');do ~/.gem/ruby/2.5.0/bin/travis logs $jobid > ~/travis-jobs/detailed/$jobid;done

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
