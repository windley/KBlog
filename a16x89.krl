ruleset a16x89 {
    meta {
        name "KBlog Data"
        description <<
            Kynetx Impact Blog demo, based on code and idea from Ed Orcutt
    
            Application Variables:
                app:BlogArticles {}
        >>
        author "Phil Windley"
        logging on
        
    }

    dispatch {
    }

    global { 
        mk_article = function (author, title, body) {
          postTime = time:now({"tz":"America/Denver"});
          { postTime : {
                "author" : author,
                "title"  : title,
                "body"   : body,
                "time"   : postTime
            }
          }
        }
        
    }
    
      rule place_clear_button {
        select when pageview "kblog"
        pre {
          button = <<
    <li><a href="javascript:void(0);" id="siteNavClear">Clear</a></li>
           >>;
        }
        {
         prepend("#navlist", button);
         watch("#siteNavClear",  "click");
        }
      }

    // ========================================================================
    rule data_reset is active {
        select when click "#siteNavClear"
        { noop(); }
        always {
            clear app:BlogArticles;
        }
    }
    
    // ========================================================================
    rule retrieve_data {
      select when explicit need_blog_data
      noop();
      always {
        raise explicit event blog_data_ready for a16x88 with
          blogdata = app:BlogArticles || []
      }
    }

    // ========================================================================
    rule add_article {
        select when explicit new_article_available
        pre {
            postHash = mk_article(event:param("postauthor"),
                                  event:param("posttitle"),
                                  event:param("postbody"));
            BlogArticles = app:BlogArticles || {};
        }
        //notify("Storing data", postTitle);
        always {
            set app:BlogArticles BlogArticles.put(postHash);
            raise explicit event new_article_added for a16x88;
        }
    }

}
