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
        use module a16x93 alias config

        provides get_articles
    }

    dispatch {
    }

    global { 
        get_articles = function () {
            app:BlogArticles || [];
        };
        
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
        config:place_button("Clear");
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
      pre {}   
      always {
        raise explicit event blog_data_ready for a16x88 with
          blogdata = app:BlogArticles || []
      }
    }

    // ========================================================================
    rule add_article {
        select when explicit new_article_available
        pre {
            post = event:param("post");
            postHash = mk_article(post.pick("$..postauthor"),
                                  post.pick("$..posttitle"),
                                  post.pick("$..postbody"));
            BlogArticles = app:BlogArticles || {};
        }
        //notify("Data", post) with sticky = true;
        always {
            set app:BlogArticles BlogArticles.put(postHash);
            raise explicit event new_article_added for a16x88;
        }
    }
    







}
