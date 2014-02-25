ruleset a16x88 {
  meta {
    name "KBlog"
    description <<
     Ruleset for creating the main pages for KBlog, a demo blog app written in KRL
    >>
    author "Phil Windley"
    logging on
    //use css resource "http://www.windley.com/kblog/kblog.css"
    //use javascript resource "http://www.windley.com/kblog/jquery.hashchange-1.js" 
    //use module a16x89 alias blogdata
    use module a16x93 alias blogconfig
  }

  dispatch {
    domain "windley.com"
  }

  global {
      
      
  
  }
  
  rule init_html {
    select when pageview ".*" setting ()
    {
      replace_inner("#about", blogconfig:about_text);
      blogconfig:place_button("Home");
      blogconfig:place_button("Contact");
      emit <|  
        self.document.location.hash='!/';
        $KOBJ(window).hashchange(function() { 
          if(KOBJ.a16x88.previous == undefined || KOBJ.a16x88.previous != self.document.location.hash) {
           var app = KOBJ.get_application("a16x88");
           app.raise_event("hash_change",{"newhash": self.document.location.hash});
           KOBJ.a16x88.previous = self.document.location.hash;
          }
        });
      |>;
      
    }
    always {
      raise explicit event blog_ready
    }
  }
  
  rule hash_change is inactive {
    select when web hash_change
    pre {
      hash = event:param("newhash");
    }
    notify("The hash changed!",hash)
  }

 
  rule show_contact {
    select when web click "#siteNavContact"
             or web hash_change newhash "/contact$"
    pre {
      contact_html = <<
       <h2 class="mainheading">Contact</h2>
        <article class="post">
          <p>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas a diam eget velit fringilla consequat. Duis nec justo urna, at tempus augue. Curabitur tristique, mi vitae ultrices lacinia, ante odio auctor odio, quis bibendum nulla augue quis diam. Aenean commodo justo ac leo cursus porttitor.
          </p>
        </article>
      >>;
      title = config:blogtitle + " - Contact";
    }
    {
    blogconfig:paint_container(title, contact_html);
    blogconfig:update_frag("/contact");
    }
  }
  
  rule show_home {
    select when web click "#siteNavHome"
             or web hash_change newhash "/$"
             or explicit blog_ready 
                 
    pre {
      container = <<
 <h2 class="mainheading">Latest from the blog</h2>
 <div id="blogarticles">Code Monkey was here :)</div>
     >>;
     title = config:blogtitle;
    }
    {
      blogconfig:paint_container(title, container);
      blogconfig:update_frag("/");
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
          postArticle = <<
              <article class="post">
                <header>
                  <h3>Title: #{postHash.pick("$.title")}</h3>
                  <span class="author">by #{postHash.pick("$.author")}</span>
                </header>
                <p>#{postHash.pick("$.body")}</p>
                <footer>
                  <p class="postinfo">Published on <time>#{postHash.pick("$.time")}</time></p>
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
