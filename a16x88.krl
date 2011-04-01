ruleset a16x88 {
  meta {
    name "KBlog"
    description <<
     Ruleset for creating the main pages for KBlog, a demo blog app written in KRL
    >>
    author "Phil Windley"
    logging on
  }

  dispatch {
    domain "windley.com"
  }

  global {

    blogtitle = "Kynetx Blog";
    about_text = <<
<p>The Kynetx Blog is built entirely with <a href="http://developer.kynetx.com">KRL</a>, the Kynetx Rule Language.
Three separate rulesets control the operation of the Kynetx Blog</p>
     >>;
    
   paint_container = defaction(title, container) {
     {
       replace_html("title", title);
       replace_html("#leftcontainer", container);
     }
    }

  }

  rule init_html {
    select when pageview ".*" setting ()
    {
      replace_html("#about", about_text);
      watch("#siteNavHome",  "click");
      watch("#siteNavContact", "click");
    }
    always {
      raise explicit event blog_ready
    }
  }
  
  rule show_contact {
    select when web click "#siteNavContact"
    pre {
      contact_html = <<
      <div id="leftcontainer">
        <h2 class="mainheading">Contact</h2>
        <article class="post">
          <p>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas a diam eget velit fringilla consequat. Duis nec justo urna, at tempus augue. Curabitur tristique, mi vitae ultrices lacinia, ante odio auctor odio, quis bibendum nulla augue quis diam. Aenean commodo justo ac leo cursus porttitor.
          </p>
        </article>
      </div>
      >>;
      title = <<
<title>#{blogtitle} - Contact</title>
      >>;
    }
    paint_container(title, contact_html)
  }
  
  rule show_home {
    select when web click "#siteNavHome"
             or explicit blog_ready 
                 
    pre {
      container = <<
<div id="leftcontainer">
 <h2 class="mainheading">Latest from the blog</h2>
 <div id="blogarticles">Code Monkey was here :)</div>
</div>
     >>;
     title = <<
<title>#{blogtitle}</title>
    >>;
    }
    {
      paint_container(title, container);
    }
    always {
      raise explicit event container_ready;
      raise explicit event need_blog_data for a16x89
    }
  }
  
  rule show_new_article {
    select when explicit new_article_added
    pre {}
    always {
      raise explicit event blog_ready
    }
  }
  
  rule show_articles {
    select when explicit container_ready
            and explicit blog_data_ready
             
     foreach event:param("blogdata") setting (postKey,postHash)
      pre {
          postAuthor = postHash.pick("$.author");
          postTitle  = postHash.pick("$.title");
          postBody   = postHash.pick("$.body");
          postTime   = postHash.pick("$.time");
          postArticle = <<
              <article class="post">
                <header>
                  <h3>#{postTitle}</h3>
                  <span class="author">by #{postAuthor}</span>
                </header>
                <p>#{postBody}</p>
                <footer>
                  <p class="postinfo">Published on <time>#{postTime}</time></p>
                </footer>
              </article>
          >>;
      }
      {
          //notify("author: ", postAuthor) with sticky = true;
          prepend("div#blogarticles", postArticle);
      }
  }
}
