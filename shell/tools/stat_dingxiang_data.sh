#!/bin/bash

dingxiang_total="data/swap/dingxiang_data_normalized"

valid_total="data/temp/pre_online.dingxiang.tag_type"
valid="data/swap/dingxiang_final_objs_data"
dead_links="conf/obj_black_list"
not_download="data/temp/pre_online.dingxiang.urls_to_download"

no_tag="data/temp/pre_online.dingxiang.no_tag"
no_type="data/temp/pre_online.dingxiang.no_type"
conflict="data/temp/pre_online.dingxiang.type_conflict"

dingxiang_total_out="data/temp/dingxiang.total"

valid_total_out="data/temp/dingxiang.total_valid"
valid_out="data/temp/dingxiang.valid"
dead_links_out="data/temp/dingxiang.deadlinks"
not_download_out="data/temp/dingxiang.not_download"

no_tag_out="data/temp/dingxiang.no_tag"
no_type_out="data/temp/dingxiang.no_type"
conflict_out="data/temp/dingxiang.type_conflict"

stat_out="data/temp/dingxiang.stat_out"

echo "Stat total..."
perl -lne '{
	if ($_ =~ /(\w+\.\w+)\/.*?(\w+\.\w+)\//) {
		print $2;
	}
}' $dingxiang_total | awk '{
	cnt[$1]++;
} END {
	for (site in cnt) {
		print site "\t" cnt[site];
	}
}' > ${dingxiang_total_out}

echo "Stat total valid..."
perl -lne '{
	if ($_ =~ /(\w+\.\w+)\/.*?(\w+\.\w+)\//) {
		print $2;
	}
}' $valid_total | awk '{
	cnt[$1]++;
} END {
	for (site in cnt) {
		print site "\t" cnt[site];
	}
}' > ${valid_total_out}

echo "Stat valid..."
awk -F'\t' '{
	split($NF, arr, "-");
	site = arr[1];
	type = arr[2];
	cnt[site]++;
	if (types[site] == "") {
		types[site] = type;
	} else if (!index(types[site], type)) {
		types[site] = types[site] "," type;
	}
	
} END {
	for (site in cnt) {
		print site "\t" types[site] "\t" cnt[site];
	}

}' $valid > ${valid_out}


echo "Stat dead links..."
awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		obj[$1] = 1;
	} else {
		if ($1 in obj) {
			print;
		}
	}
}' ${dingxiang_total} ${dead_links} | perl -lne '{
	if ($_ =~ /(\w+\.\w+)\//) {
		print $1;
	}
}' | awk '{
	cnt[$1]++;
} END {
	for (site in cnt) {
		print site "\t" cnt[site];
	}
}' > ${dead_links_out}

echo "Stat not download..."
awk -F'\t' '{
	split($NF, arr, "-");
	site = arr[1];
	type = arr[2];
	cnt[site]++;
} END {
	for (site in cnt) {
		print site "\t" cnt[site];
	}

}' $not_download > ${not_download_out}


echo "Stat no tag..."
perl -lne '{
	if ($_ =~ /(\w+\.\w+)\/.*?(\w+\.\w+)\//) {
		print $2;
	}
}' ${no_tag} | awk '{
	cnt[$1]++;
} END {
	for (site in cnt) {
		print site "\t" cnt[site];
	}
}' > ${no_tag_out}

echo "Stat no type..."
perl -lne '{
	if ($_ =~ /(\w+\.\w+)\/.*?(\w+\.\w+)\//) {
		print $2;
	}
}' ${no_type} | awk '{
	cnt[$1]++;
} END {
	for (site in cnt) {
		print site "\t" cnt[site];
	}
}' > ${no_type_out}


echo "Stat conflict..."
perl -lne '{
	if ($_ =~ /(\w+\.\w+)\/.*?(\w+\.\w+)\//) {
		print $2;
	}
}' ${conflict} | awk '{
	cnt[$1]++;
} END {
	for (site in cnt) {
		print site "\t" cnt[site];
	}
}' > ${conflict_out}

echo "Merge..."
awk -F '\t' '{
	if (FILENAME == ARGV[1]) {
		site_cnt[$1] = $2;
	} else if (FILENAME == ARGV[2]) {
		types[$1] = $2;
		valid_cnt[$1] = $3;
	} else if (FILENAME == ARGV[3]) {
		dead_links_cnt[$1] = $2;
	} else if (FILENAME == ARGV[4]) {
		not_download_cnt[$1] = $2;
	} else if (FILENAME == ARGV[5]) {
		no_tag_cnt[$1] = $2;
	} else if (FILENAME == ARGV[6]) {
		no_type_cnt[$1] = $2;
	} else if (FILENAME == ARGV[7]){
		conflict_cnt[$1] = $2;
	} else {
		total_cnt[$1] = $2;
	}

} END {
	for (s in site_cnt) {
		print s "\t" total_cnt[s] "\t" types[s] "\t" site_cnt[s] "\t" valid_cnt[s] "\t" dead_links_cnt[s] "\t" not_download_cnt[s] "\t" no_tag_cnt[s] "\t" no_type_cnt[s] "\t" conflict_cnt[s];
	}
}' ${valid_total_out} ${valid_out} ${dead_links_out} ${not_download_out} ${no_tag_out} ${no_type_out} ${conflict_out} ${dingxiang_total_out} > ${stat_out}

echo "Finished. Out file: " ${stat_out}
