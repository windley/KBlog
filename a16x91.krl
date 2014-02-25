ruleset a16x91 {
  meta {
    name "KBlog Tweetter"
    description <<
     Add tweeting of blog posts to KBlog
    >>
    author "Phil Windley"
    logging off
    key twitter {
      "consumer_key" : "<redacted>",
      "consumer_secret" : "<redacted>",
      "oauth_token" : "<redacted>",
      "oauth_token_secret" : "<redacted>"
    }
  }

  dispatch {
  }

  global {

  }

  rule place_checkbox {
    select when explicit post_form_ready
    pre {
      form_id = event:param("form_id");
      checkbox_html = <<
<p class="checkbox">
  <label for="posttitle"><small>Post to Twitter?</small></label>
  <input name="tweet" id="tweet" value="1" type="checkbox" checked="checked">
</p>
      >>;
    }
    after(".text-area", checkbox_html);
  }
  
  rule send_tweet {
    select when explicit new_article_available
    pre {
      post = event:param("post");
      author = post.pick("$..postauthor");
      title = post.pick("$..posttitle");
      tweet = <<
New blog post from #{author}: #{title}
http://www.windley.com/kblog 
>>;
    }  
    if (post.pick("$..tweet",true).length() && twitter:authorized()) then {
      notify("Tweet", "Would update twitter with #{tweet}") with sticky = true;
      twitter:update(tweet);
    }
  }
}
