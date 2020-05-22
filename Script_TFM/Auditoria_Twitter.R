#################################################
#####   SCRIPT TO AUDIT THE TWITTER USERS   #####
#################################################

name <- readline(prompt=" Twitter username: ")
user <- lookup_users(name)

if(length(user)==0){
  cat('------------------------------------------', sep = '\n')
  cat('  ¡WARNING! Possible anomalies:', sep = '\n')
  cat('     1. This user does NOT exist', sep = '\n')
  cat('     2. Twitter API disconnection', sep = '\n')
  cat('------------------------------------------', sep = '\n')
} else{
  
  #################################
  ###  NEW PATH AND NEW FOLDER  ###
  #################################
  new_dir=paste0("~/R/",name,"_", format(Sys.Date(), format = "%d-%m-%Y"))  #SET A NEW USER-PATH
  dir.create(new_dir)  #CREATE A NEW FOLDER WITH THIS PATH
  setwd(new_dir)  #CHANGE THE WORKDIRECTORY TO THE NEW PATH
  
  #######################
  ###  PERSONAL DATA  ###
  #######################
  picture<-substring(user$profile_image_url, first = 1, last = nchar(user$profile_image_url)-10) #EXTRACT THE LAST PART OF THE STRING IN ORDER TO CHANGE 'nomal' BY '400*400' TO SET THE SIZE
  download.file(paste0(picture,'400x400.jpg'),paste0(name,'_profile.jpg'), mode = 'wb') #DOWNLOAD THE USER PICTURE
  download.file(user$profile_banner_url, paste0(name,'_bg.jpg'), mode = 'wb') #DOWNLOAD THE USER BACKGROUND
  
  ######################
  ###  TWITTER DATA  ###
  ######################
  timeline <- get_timeline(name, n=200) 
  external_mentions <- search_tweets(paste0('@',name), n=150)
  friends <- get_friends(name, retryonratelimit = TRUE)
    n_fr <- length(friends$user_id)  #NUMBER OF FRIENDS DOWNLOADED (MAX 5000)
  followers <- get_followers(name, retryonratelimit = TRUE)
    n_fol <- nrow(followers)  #NUMBER OF FOLLOWERS DOWNLOADED (MAX 5000)
    
  ######################
  ###  EXPORT  DATA  ###  
  ######################  
  # (THIS DATA WILL BE ANALYZED USING PYTHON)
    
  ### RETWEETS ID's
  timeline_retweets <- unlist(timeline[timeline$is_retweet,]$mentions_screen_name)
  write(timeline_retweets, paste0(name, '_timeline_retweets.txt'))
  ### USER MENTIONS ID's
  timeline_mentions <- unlist(timeline[!timeline$is_retweet,]$mentions_screen_name)
  txt_tl_mention <- timeline_mentions[!is.na(timeline_mentions)]
    write(txt_tl_mention, paste0(name, '_own_mentions.txt'))
  ### EXTERNAL USER MENTIONS ID's
  txt_external_mentions_ids <- external_mentions$screen_name
    write(txt_external_mentions_ids, paste0(name, '_external_mentions.txt'))
  ### FRIENDS ID's
  if(n_fr <= 150){
      txt_fr <- unlist(friends$user_id)
      write(txt_fr, paste0(name, '_friends.txt'))
  }else{
      txt_fr <- unlist(friends$user_id[sample(1:n_fr,150)])
      write(txt_fr, paste0(name, '_friends.txt'))
  }
  ### FOLLOWERS ID's
  if(n_fol <= 150){
      txt_fol <- unlist(followers)
      write(txt_fol, paste0(name, '_followers.txt'))
  }else{
      txt_fol <- unlist(followers)[(sample(1:n_fol,150))]
      write(txt_fol, paste0(name, '_followers.txt'))
  }
  ##########################
  ###  PLOTS AND TABLES  ###  
  ##########################
  
  ### TIMELINES ###
  df_tl <- timeline %>% select("created_at") 
  df_tl_own <- timeline[!timeline$is_retweet,] %>% select("created_at") 
  df_tl_rt <- timeline[timeline$is_retweet,] %>% select("created_at") 
  
  df_tl$N <- length(df_tl$created_at):1
  df_tl_own$N <- length(df_tl_own$created_at):1
  df_tl_rt$N <- length(df_tl_rt$created_at):1
  
  df_tl$Tipo<-rep('Timeline',length(df_tl$created_at))
  df_tl_own$Tipo<-rep('Tweet',length(df_tl_own$created_at))
  df_tl_rt$Tipo<-rep('Retweet',length(df_tl_rt$created_at))
  df_all<-rbind(df_tl_own, df_tl_rt)
  
  t_0 = min(df_tl$created_at)-60*60
  t_1 = max(df_tl$created_at)+60*60
  
  df_tl %>% #FREQ OF TIMELINE
    ts_plot('hour', color='aquamarine4') + 
    theme_minimal() + xlim(t_0, t_1) +
    theme(plot.title = element_text(face = "bold"), axis.text.x=element_text(angle=30, hjust=1, size=12)) +
    labs(x = NULL, y = NULL, title = paste0('Timeline de @',name), subtitle = "Frecuencia de las publicaciones") -> plot_freq_tl 
  df_tl %>% #ACUMULATIVE OF TIMELINE
    ggplot(aes(x = created_at, y = N)) +
    geom_area(color="aquamarine4", fill='aquamarine', alpha=0.2) +
    theme_minimal() + xlim(t_0, t_1) +
    labs(x = NULL, y = NULL, title=paste0('Timeline de @',name), subtitle = 'Cantidad total de publicaciones') +
    theme(plot.title = element_text(face = "bold"), axis.text.x=element_text(angle=30, hjust=1, size=12)) -> plot_ac_tl 
  
  df_all %>% #FREQ OF TWEETS-RETWEETS
    mutate(Tipo = factor(as.factor(Tipo), levels(as.factor(Tipo))[c(2,1)])) %>% 
    dplyr::group_by(Tipo) %>%
    ts_plot("hour") +
    theme_minimal() + xlim(t_0, t_1) +
    labs(x = NULL, y = NULL, title = paste0('Desglose del timeline de @',name), subtitle = "Frecuencia de las publicaciones") + 
    scale_color_manual(values=c("aquamarine2", "aquamarine3")) +
    theme(plot.title = element_text(face = "bold"),
          axis.text.x=element_text(angle=30, hjust=1, size=12),
          legend.position = "bottom",legend.title = element_blank()) -> plot_freq_all 
  df_all %>% #AC OF TWEETS-RETWEETS
    mutate(Tipo = factor(as.factor(Tipo), levels(as.factor(Tipo))[c(2,1)])) %>% 
    ggplot(aes(x=created_at, y=N, fill=Tipo, text=Tipo)) + 
    geom_area(color='aquamarine4', size=0.2, alpha=0.2) +
    theme_minimal() + xlim(t_0, t_1) +
    labs(x = NULL, y = NULL, title=paste0('Desglose del timeline de @',name), subtitle = 'Cantidad total de publicaciones') +
    scale_fill_manual(values=c("aquamarine2", "aquamarine3")) +
    theme(plot.title = element_text(face = "bold"),
          axis.text.x=element_text(angle=30, hjust=1, size=12),
          legend.position = "bottom",legend.title = element_blank()) -> plot_ac_all
  
  
  ### CONVERT TO HTML FORMAT ###
  plotly_freq_tl <- ggplotly(plot_freq_tl)
  plotly_ac_tl <- ggplotly(plot_ac_tl)
  plotly_freq_all <- ggplotly(plot_freq_all) 
  plotly_ac_all <- ggplotly(plot_ac_all)
  
  ### SAVE THE PLOTS ###
  pdf(paste0(name, '_timeline_freq.pdf'))
    print(plot_freq_tl)
  dev.off()
  pdf(paste0(name, '_timeline_ac.pdf'))
    print(plot_ac_tl)
  dev.off()
  pdf(paste0(name, '_tw-retw_freq.pdf'))
    print(plot_freq_all)
  dev.off()
  pdf(paste0(name, '_tw-retw_ac.pdf'))
    print(plot_ac_all)
  dev.off()
  
  saveWidget(plotly_freq_tl, paste0(name, '_timeline_freq.html'))
  saveWidget(plotly_ac_tl, paste0(name, '_timeline_ac.html'))
  saveWidget(plotly_freq_all, paste0(name, '_tw-retw_freq_freq.html'))
  saveWidget(plotly_ac_all, paste0(name, '_tw-retw_freq_ac.html'))
}

setwd('~/R')

cat(' ', sep = '\n')
cat(' --------------------------------------', sep = '\n')
cat('     Audit succesfulyl done', sep = '\n')
cat(' --------------------------------------', sep = '\n')
cat(' ', sep = '\n')

