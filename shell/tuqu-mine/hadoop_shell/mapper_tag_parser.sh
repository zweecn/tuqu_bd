#!/bin/bash

perl -MEncode -F"\t" -lane '{
#    @sites=("duitang.com/people/mblog/","diandian.com/post/","huaban.com/pins/","faxianla.com/mark/","zhimei.com/share/","pinfun.com/pin/","mishang.com/pin/","woxihuan.com","zhan.renren.com","tuita.com","topit.me/item/","topit.me/album/","fishcan.net","xiachufang.com/recipe/","juetuzhi.net","ycy8.net","www.meilishuo.com/share","www.digu.com/pin/","tuchong.com","www.mogujie.com/note");
#   $go_on=0;
#    foreach $site(@sites)
#    {
#        if(index($F[1],$site)>=0)
#        {
#            $go_on=1;
#            last;
#        }
#    }
#    next if($go_on==0);
	next if(index($F[1],"diandian.com/post")<=-1);
	$str= `wdbdtools/query.sh wdbd "$F[1]" PAGE`;
    $str=~s/\s+/ /g;
    $album="";
    $desc="";
    $tags = "";
#   http://www.duitang.com/people/mblog/8676967/detail/
	if($F[1] =~ /http:\/\/www\.duitang\.com\/people\/mblog\/[0-9]+\/detail\//)
	{
        if($str=~/<a href=\"\/album\/[0-9]+\" title=\"[^\"]+\">([^<]+)<\/a>/)
        {
            $album=$1;
        }
        if($str=~/<a href=\"\/album\/[0-9]+\/\">([^<]+)<\/a>/)
        {
            $album=$1;
        }
        if($str=~/<meta name=\"description\" content=\"([^\"]+)\" \/>/)
        {
            $desc=$1;
        }
		while($str =~ /<a href=\"\/blogs\/tag\/[^\"]+\">([^<]+)<\/a>/g)
		{
			    $tags .="\$\$".$1;
		}
        $tags=~s/^\$\$//;
	}
    #http://chiscat.diandian.com/post/2012-02-09/15417277
	elsif($F[1] =~ /http:\/\/[a-z]+\.diandian.com\/post\/[0-9]{4}-[0-9]{2}-[0-9]{2}\/[0-9]+/)
	{
		if($str =~ /<title>([^_]+)_([^<]+)/)
		{
			$desc = $1;
			$album = $2;
		}
		if($str=~/<ul class=\"tags\">(.+?)<\/ul>/){
			$tags_str=$1;
			while($tags_str=~/<a href=\"[^\"]+\"[^>]+>([^<]+)<\/a>/g){
				$tags.="\$\$".$1;
			}
		}elsif($str=~/<div class=\"tag-list\">(.+?)<\/div>/){
			$tags_str=$1;
			while($tags_str=~/<a href=\"[^\"]+\"[^>]+>([^<]+)<\/a>/g){
				$tags.="\$\$".$1;
			}
			$tags=~s/^\$\$//;
		}elsif($str=~/<div class=\"post-tags\">(.+?)<\/div>/){
			$tags_str=$1;
			while($tags_str=~/<a href=\"[^\"]+\"[^>]+>([^<]+)<\/a>/g){
				$tags.="\$\$".$1;
			}
			$tags=~s/^\$\$//;
		}
		$tags=~s/^\$\$//;
	}

# todo add www.mougujie.com
    # http://huaban.com/pins/2343579
    elsif($F[1] =~ /http:\/\/huaban\.com\/pins\/[0-9]+/)
    {
        if($str=~/<div id=\"pin_caption\" class=\"pin-caption\"><p class=\"text\">([^<]+)<\/p>/)
        {
            $desc=$1;
        }
        if($str=~/<div data-id=\"[0-9]+\" data-seq=\"[0-9]+\" class=\"Board wfc ?\"><h3>([^<]+)<\/h3>/)
#        if($str=~/(<div data-id=\"[0-9]+\" data-seq=\"[0-9]+\" class=+>)/)
        {
            $album=$1;
        }
    }
    #http://faxianla.com/mark/17276
    elsif($F[1]=~/http:\/\/faxianla\.com\/mark\/[0-9]+/)
    {
        if($str=~/<div id=\"mark_desc\">([^<]+)</)
        {
            $desc=$1;
        }
        if($str=~/<a href=\"\/board\/[0-9]+\">([^<]+)<\/a>/)
        {
            $album=$1;
        }
    }
    #http://www.zhimei.com/share/8085
    #remind 库和网站网页不同
    elsif($F[1]=~/http:\/\/www\.zhimei\.com\/share\/[0-9]+/)
    {
        if($str=~/<title>([^-]+)-([^-]+)-[^<]+<\/title>/)
        {
            $desc=$1;
            $album=$2;
        }
        if($str=~/href=\"\/board\/[0-9]+\/[0-9]+\"[^>]+>([^<]+)<\/a>/)
        {
            $album=$1;
        }
        if($str=~/<div class=\"desc\">([^<]+)<\/div>/)
        {
            $desc=$1;
        }
        if($str=~/<meta property=\"og:description\" content=\"([^\"]+)\"/)
        {
            $desc=$1;
        }
		while($str =~ /<a class=\"defaultlabel\" href=\"\/tagSearch\/[0-9]+\" target=\"_blank\"><em>([^<]+)<\/em>/g)
		{
			    $tags .="\$\$".$1;
		}
        $tags=~s/^\$\$//;
    }
    # http://www.pinfun.com/pin/54808/
    elsif($F[1]=~/http:\/\/www\.pinfun\.com\/pin\/[0-9]+/)
    {
#        if($str=~/<title>([^\/]+)\/([^<]+)<\/title>/)
#        {
#            $desc=$1;
#            $album=$2;
#        }
        if($str=~/<meta name=\"Description\" content=\"([^\"]+)\"/)
        {
            $desc=$1;
        }
#todo 时效性问题 www.pinfun.com
    }
    #http://www.mishang.com/pin/4f4aecaa1d41c804e00010a2/
    elsif($F[1]=~/http:\/\/www\.mishang\.com\/pin\/[0-9a-z]+\//)
    {
        if($str=~/<title>([^-]+)-([^-]+)-[^<]+<\/title>/)
        {
            $desc=$1;
            $album=$1;
        }
        if($str=~/<title>([^迷]+)迷尚网 mishang.com<\/title>/)
        {
            $desc=$1;
        }
        if($str=~/<div class=\"bordNameH1\"><h1>([^<]+)<\/h1><\/div>/)
        {
            $album=$1;
        }
    }
#todo 人人逛街 j.renren.com 没有数据
#todo www.buykee.com 没有数据
    #http://www.woxihuan.com/28028440/1329041143086335.shtml 
    #remind 网页和库中的html代码不一样
    elsif($F[1]=~/http:\/\/www\.woxihuan\.com\/[0-9]+\/[0-9]+\.shtml/)
    {
        if($str=~/<title>([^_]+)_[^<]+<\/title>/)
        {
            $desc=$1;
        }
		if($str=~/<a class=\"link\" href=\"\/album\/[^\"]+>([^<]+)</){
			$album=$1;	
		}
		if($str=~/<a href=\"\/album\/[0-9]+\/[0-9]+\.shtml\" class=\"albumTitle\">([^<]+)<\/a/){
           $album=$1." ".$album;
       }
	}
    #todo idsoo.com没有数据
    #http://zhan.renren.com/last3days?tagid=112598&page=2&from=pages&checked=true
    elsif($F[1]=~/http:\/\/zhan\.renren\.com\/[0-9a-z]+/)
    {
        @parts=split("<article class=\"post-article post\" id=\"feed_[0-9]+\" authorId=\"[0-9]+\" replyCount=\"[0-9]+\"",$str);
#        @parts=split("<article class=\"post-article post\" id=\"feed_[0-9]+\" authorid=",$str);
#print "parts length=".scalar(@parts);
         $obj=$F[0];
         # 需要特殊处理 <img src="http://110.81.153.181/qq_news//tech/pics/63/63425/63425031_168_208.jpg 
         $obj=~s/\/\//\//g;
#        $count=1;
         foreach $part(@parts)
         {
            $part=~s/\/\//\//g;
            next if(index($part,$obj)<0);
            @article_split=split("<\/article>",$part);
#            print "article_split length=".scalar(@article_split);
            $part=$article_split[0];
#print "find obj";
# print $count;
# $count=$count+1;
            while($part=~/a href=\"http:\/zhan\.renren\.com\/tag\?value=[^\"]+\">([^<]+)<\/a>/g)
            {
                $tags.="\$\$".$1
            }
            if($part=~/<h4 class=\"title\">([^<]+)<\/h4>/)
            {
                $desc=$1;
            }
        }
        $tags=~s/^\$\$//;
        $tags=~s/# //g;
   }
    #http://a1.att.hudong.com/46/44/05300000844289126935443899717.jpg	http://www.tuita.com/tagpage/杩樺師/all?page=2	
    #remind 库和网站的网页不同
    elsif($F[1]=~/http:\/\/www\.tuita\.com\/tagpage\//)
    {
#        <div attr="inner:root" emma="feedItem" class="feed_group hide_face"
        @parts=split("<div attr=\"inner:root\" emma=\"feedItem\" class=\"feed_group hide_face\"",$str);
        foreach $part(@parts)
        {
            next if(index($part,$F[0])<0);
            $part=~s/\s+/ /g;
            while($part=~/<a href=\"http:\/\/www\.tuita\.com\/tagpage\/[^\/]+\/selected\" title=\"[^\"]+\">([^<]+)<\/a>/g)
            {
                $tags.="\$\$".$1;
            }
            if($part=~/<h2 class=\"title\">([^<]+)<\/h2>/)
            {
                $desc=$1;
            }
        }
        $tags=~s/^\$\$//;
        $tags=~s/#//g;
    }
    #http://topit.me/item/1955095  OR http://topit.me/album/143068/item/994032?p=2 
    elsif($F[1]=~/http:\/\/topit\.me\/item\/[0-9]+/ || $F[1]=~/http:\/\/topit\.me\/album\/[0-9]+\/item\//)
    {
        if($str=~/<title>([^-]+)-- TOPIT.ME 收录优美图片<\/title>/)
        {
            $desc=$1;
        }
        while($str=~/<a href=\"http:\/\/www\.topit\.me\/tag\/[^\"]+\">([^<]+)<\/a>/g)
        {
                $tags .="\$\$".$1;
        }
        $tags=~s/^\$\$//;
        if($str=~/<div class=\"userinfo_blk\"><h2>([^<]+)<\/h2>/)
        {
            $album=$1;
        }
    }
    # http://fishcan.net/4098.html
    elsif($F[1]=~/http:\/\/fishcan\.net\/[0-9]+\.html/)
    {
        while($str=~/rel=\"category tag\">([^<]+)<\/a>/g)
        {
            $tags .="\$\$".$1;
        }
		$tags =~ s/\//\$\$/g;
        $tags=~s/^\$\$//;
        if($str=~/<title>([^|]+)| 鱼罐头[^美]美好视界<\/title>/)
        {
            $desc=$1;
        }
    }
    #http://www.xiachufang.com/recipe/166723/?via=rel
    # todo http://www.xiachufang.com/recipe/86839/dishes/  数据中没有这类fromURL
    elsif($F[1]=~/http:\/\/www\.xiachufang\.com\/recipe\/[0-9]+\//)
    {
        if($str=~/<h1 class=\"g-page-title\"[^>]*>([^<]+)<\/h1>/)
        {
            $desc=$1;
        }
        while($str=~/<a href=\"\/recipe_list\/[0-9]+\/\" title=\"[^\"]+\">([^<]+)<\/a>/g)
        {
            $album .="\$\$".$1;
        }
        $album=~s/^\$\$//;
    }
    #todo http://juetuzhi.net/category/funny/page/343 一个网页对应多张图片
    elsif($F[1]=~/http:\/\/juetuzhi\.net\/category\/[a-z0-9]+\/page\/[0-9]+/)
    {
        @parts=split("<div class=\"box-left\" id=\"post-[0-9]+\">",$str);
        $obj=$F[0];
        $obj=~s/http:\/\/[^\/]+/http:\/\/site/;
        foreach $part(@parts)
        {
            $part=~s/http:\/\/[^\/]+/http:\/\/site/g;
            #  print $part;
            next if(index($part,$F[0]));
            #print "find obj";
            #todo 从库中取出的网页中没有对象的OBJ  
            if($str=~/<title>([^\|]+)\| 掘图志<\/title>/)
            {
                $desc=$1;
            }
            while($str=~/href=\"http:\/\/juetuzhi\.net\/tag\/[^\"]+\" rel=\"tag\">([^<]+)</g)
            {
                $tags .="\$\$".$1;
            }
            $tags=~s/^\$\$//;
        }
    }
    #http://juetuzhi.net/2008/10/lamborghini-gallardo-lp560-for-the-italian-police.html 
    #一个网页一个图片
    elsif($F[1]=~/http:\/\/juetuzhi\.net\/[0-9]{4}\/[0-9]{2}\/[^\.]+\.html/)
    {
        if($str=~/<title>([^\|]+)\| 掘图志<\/title>/)
        {
            $desc=$1;
        }
        while($str=~/href=\"http:\/\/juetuzhi\.net\/tag\/[^\"]+\" rel=\"tag\">([^<]+)</g)
        {
            $tags .="\$\$".$1;
        }
        $tags=~s/^\$\$//;
    }
    #todo http://photo.poco.cn/like/detail-upi-tpl_type-album-topic_id-1687-item_id-151449386-item_num-1.html 低优先级
    #
    elsif($F[1]=~/http:\/\/www\.xiachufang\.com\/recipe\/[0-9]+\//)
    {
        if($str=~/<h1 class=\"g-page-title\"[^>]*>([^<]+)<\/h1>/)
        {
            $desc=$1;
        }
        while($str=~/<a href=\"\/recipe_list\/[0-9]+\/\" title=\"[^\"]+\">([^<]+)<\/a>/g)
        {
            $album .="\$\$".$1;
        }
    }
    #http://www.ycy8.net/2010_4425.html
    elsif($F[1]=~/http:\/\/www\.ycy8\.net\/[0-9]{4}_[0-9]+\.html/)
    {
#      if($str=~/<title>([^\|]+)\| 有创意吧[^享]+享受生活创意设计,创意家居设计,创意产品设计,摄影作品,素材下载    <\/title>/)
        if($str=~/<title>([^\|]+)\| 有创意吧[^<]+<\/title>/)
        {
            $desc=$1;
        }
        #href="http://www.ycy8.net/tag/%e5%88%9b%e6%84%8f%e8%ae%be%e8%ae%a1">创意设计</A> <A 
        while($str=~/href=\"http:\/\/www\.ycy8\.net\/tag\/[^\"]+\" rel=\"tag\">([^<]+)</g)
        {
            $tags .="\$\$".$1;
        }
        $tags=~s/^\$\$//;
        if($str=~/href=\"http:\/\/www\.ycy8\.net\/[a-z]+\" title=\"[^\"]+\" rel=\"category tag\">([^<]+)</)
        {
            $album=$1;
        }
    }
	## http://www.meilishuo.com/share/16953548
	elsif($F[1]=~/http:\/\/www\.meilishuo\.com\/share\/[0-9]+/){
		if($str=~/<title>([^-]+)-[^<]+<\/title>/){
			$desc=$1;	
		}
		if($str=~/class=\"quote_goods_title\">([^<]+)</){
			$desc=" ".$desc;
		}
		if($str=~/<a href=\"\/attr\/show\/[0-9]+\" target=\"_blank\">([^<]+)<\/a>/){
			$album=$1;	
		}
	}
	##http://www.mogujie.com/note/1gpcw
	elsif($F[1]=~/http:\/\/www\.mogujie\.com\/note\//){
		if($str=~/<title>([^-]+)-[^<]+<\/title>/){
			$desc=$1;	
		}
	}
#    
# elsif($F[1]=~/http:\/\/home\.photo\.com\/[0-9]+\/pic\//){
#                
#    }
    elsif($F[1]=~/http:\/\/jipin\.kaixin001\.com\/p\/[0-9]+/)
    {
        
    }
    # http://www.digu.com/pin/t2wdnkbqt6wn
    elsif($F[1]=~/http:\/\/www\.digu\.com\/pin\//)
    {
        while($str=~/<a href=\"\/search\/[^\"]+\">([^>]+)<\/a>/g)
        {
            $tags.="\$\$".$1;    
        }
        ##网站的推荐标签
        while($str=~/<a href=\"http:\/\/www\.digu\.com\/search\/[^\"]+\">([^<]+)<\/a>/g){
            $tags.="\$\$".$1;    
        }
        $tags=~s/^\$\$//;
        if($str=~/<p class=\"detail_info\"> <img src=[^>]+>\"([^\"])+\"/)
        {
            $desc=$1;
        }
        if($str=~/<a href=\"\/board\/detail\/[^\"]+\"><h3>([^<]+)<\/a>/)
        {
            $album=$1;
        }
        
    }
    # http://tuchong.com/100114/1864542/  OR http://tuchong.com/photo/1322/ (大库中因为跳转所以拿不到数据，站点影响面26/41)
    elsif($F[1]=~/http:\/\/tuchong\.com\/[0-9]+\/[0-9]+\//){
### <a class="tag" rel="tag" href="http://tuchong.com/100114/tags/广州/">广州</a>
        while($str=~/<a class=\"tag\" rel=\"tag\" href=\"http:\/\/tuchong\.com\/[0-9]+\/tags\/[^\"]+\">([^<]+)<\/a>/g){
            $tags.="\$\$".$1;
        }
        $tags=~s/^\$\$//;
        if($str=~/<meta name=\"description\" content=\"([^\"]+)\"/){
            $desc=$1;
        }
    }
    elsif($F[1]=~/http:\/\/fffave\.com\/view\/[0-9]+/){
        
    }
    elsif($F[1]=~/http:\/\/at\.im\/v\/[0-9]+\//){
    
    }
    elsif($F[1]=~/http:\/\/gaoxiaoo\.com\//){
        
    }
    elsif($F[1]=~/http:\/\/www\.laifu\.org\/tupian\/[0-9]+\.htm/){
    
    }
    elsif($F[1]=~/http:\/\/ikeepu\.com\/bar\/[0-9]+/){
    
    }
    elsif($F[1]=~/http:\/\/taitaitang\.com\/photos\/[0-9]+\//){
        
    }

#    print $F[0]."\t".$F[1]."\t".$tags."\t".$desc."\t".$album;
    print $_."\t".$tags."\t".$desc."\t".$album;
}'
