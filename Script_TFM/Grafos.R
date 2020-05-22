##########################################
####   SCRIPT TO CREATE HTML GRAPHS   ####
##########################################

rm(list=ls())
dir.create(paste0("~/R/Grafos_TFM_", format(Sys.Date(), format = "%d-%m-%Y")))

csv<-c('Rivera', 'Abascal', 'Casado', 'Iglesias', 'Sanchez',
       'gabrielrufian', 'junqueras','QuimTorraiPla', 'carlesral', 'KRLS',
       '10N', '155','falange', 'covid19', 'sanchezdimision', 'pin')


for(name in csv)
  {
  ### CARGA DE DATOS + CREACION DE GRAFOS
  
  setwd('~/R')
  topic<-read.csv(paste0('hoaxy_',name,'.csv'))
  
  data <- data.frame(from=topic$from_user_screen_name,
                     to=topic$to_user_screen_name,
                     stringsAsFactors = FALSE)
  
  g<-graph_from_data_frame(data)
  plot3D <- simpleNetwork(data)
  
  nodos<-as.character(plot3D$x$nodes[,1])
  
  ### PARAMETROS+IDENTIFICADORES PARA EL GRAFO
  nodes_from_graph<-c(unique(as.character(topic$to_user_screen_name)),
                      unique(as.character(topic$from_user_screen_name)))
  
  measure<-data.frame(names(8*(degree(g)/max(degree(g)))^(1/7)),
                      8*(degree(g)/max(degree(g)))^(1/7))
  names(measure)<-c('Name', 'Degree')
  measure<-arrange(measure, Name)[,2]
  
  name_sc<-c(as.character(topic$to_user_screen_name),as.character(topic$from_user_screen_name))
  bot_sc<-c(as.character(topic$to_user_botscore),as.character(topic$from_user_botscore))
  sc<-data.frame(name_sc,bot_sc)
  
  sc<-arrange(sc,name_sc,bot_sc)
  sc<-sc[ifelse(duplicated(sc[,1])==FALSE,TRUE,FALSE),]
  rownames(sc)<-NULL
  
  bot<-sc[,2]
  bot<-as.numeric(as.character(bot))
  bot[is.na(bot)]<-rep(0.8, sum(is.na(bot)))+runif(sum(is.na(bot)), -0.05, 0.05)
  
  {
    datos <- fromJSON(file = paste0('rep_', name,'_participants.txt', sep=''))
    datos <- datos$elementlist
    rep_df<-list()
    {
      account<-c()
      user<-c()
      content<-c()
      sent<-c()
      temp<-c()
      bot<-c()
      rep<-c()
    } ### RESTART THE PARAMETERS OF THE PROBLEM 
    
    for (i in c(1:length(datos))){
      
      account[i]<-(datos[[i]][["user"]][["screen_name"]])
      user[i]<-(1-datos[[i]]$categories$user)
      content[i]<-(1-datos[[i]]$categories$content)
      sent[i]<-(1-datos[[i]]$categories$sentiment)
      temp[i]<-(1-datos[[i]]$categories$temporal)
      bot[i]<-(1-datos[[i]]$scores$universal) #Bot likelihood
      rep[i]<-(user[i]*content[i]*sent[i]*temp[i]*bot[i])^(1/5)
    } 
    
    rep_df[[name]]<-data.frame(account, user, content, sent, temp, bot, rep)
  } ### OPEN THE .JSON REPUTATION FILE
  
  PR<-page_rank(g)$vector
  P_Rank<-data.frame(names=names(PR), PR)
  P_Rank<-arrange(P_Rank, names)
  rownames(P_Rank)<-NULL
  
  Clos<-(closeness(g)-min(closeness(g)))/max(closeness(g))
  Clos_df<-data.frame(names=names(Clos),Clos)
  Clos_df<-arrange(Clos_df,names)
  rownames(Clos_df)<-NULL
  
  Betw<-(betweenness(g)-min(betweenness(g)))/max(betweenness(g))
  Betw_df<-data.frame(names=names(Betw),Betw)
  Betw_df<-arrange(Betw_df,names)
  rownames(Betw_df)<-NULL
  
  
  ### MUESTREO QUE CONOCEMOS, ES DECIR, ELIMINAMOS LOS "XXX"
  v=ifelse(rep_df[[1]]$account=='XXX',FALSE,TRUE)
  sample<-data.frame(
    account=rep_df[[1]]$account[v],
    Rep_A=rep_df[[1]]$rep[v],
    Bot=rep_df[[1]]$bot[v],
    Page_Rank=P_Rank$PR[v],
    Closeness=Clos_df$Clos[v],
    Betweenness=Betw_df$Betw[v]
  )
  plot(sample[-1])
  ### CREAMOS EL GRAFO QUE DIBUJAMOS DESPUES
  {
    Links<-plot3D$x$links[,1:3]
    Nodes<-plot3D$x$nodes
    Nodes$nodesize<-round(measure, digits=2)
    Source<-plot3D$x$links$source
    Target<-plot3D$x$links$target
    Value<-plot3D$x$links$value
    NodeID<-plot3D$x$nodes$name
    Nodesize<-plot3D$x$nodes$nodesize
    Group<-plot3D$x$nodes$group
    MyClickScript <-'alert("User: " + d.name +"  |  Bot Score: " + d.bot + "%  |  " + d.group);'
  }### DE SIMPLE A FORCE NETWORK
  
  {
    Network <-forceNetwork(Links, Nodes, Source = "source",
                                   Target = "target", Value = "value", NodeID = "name", Group = "group",
                                   height = NULL, width = NULL,
                                   colourScale = JS('d3.scaleOrdinal(d3.schemeCategory10);'),
                                   fontSize = 25,
                                   fontFamily = "serif",
                                   linkDistance = 20,
                                   linkWidth = JS("function(d) { d.value; }"),
                                   radiusCalculation = JS("d.nodesize"),
                                   charge = -30,
                                   linkColour = "#deb4b4",
                                   opacity = 0.75,
                                   zoom = TRUE,
                                   legend = JS('function(d){d3.style("align"); return TRUE}'),
                                   arrows = FALSE,
                                   bounded = FALSE,
                                   opacityNoHover = 0,
                                   clickAction = MyClickScript)
    
    Network$x$nodes$nodesize<-round(measure, digits=2)
    Network$x$nodes$group<-ifelse(bot<0.2,"Real",
                                          ifelse(bot>0.2 & bot<0.5,"Medio",
                                                 ifelse(bot>0.5 & bot<0.75, "Dudoso", "Bot")))
    Network$x$nodes$bot<-round(100*as.numeric(as.character(bot)),2)
    Network$x$options$colourScale<- 'd3.scaleOrdinal(d3.schemeCategory20)
                                               .domain(["Real", "Medio" , "Dudoso", "Bot"])
                                               .range(["#6cb6ff", "#0061f3", "#ff3030", "#a80000"]);'
    Network$x$options$nodesize<-TRUE
    
    Network <- htmlwidgets::prependContent(Network, htmltools::tags$h2(paste0('Menciones: @', name)))
    Network <- htmlwidgets::onRender(Network,
                                             'function(el, x) { 
                                            d3.selectAll(".legend")
                                              .style("align", "#right")
                                              .style("position", "absolute");
                                            d3.select("body").style("background-color", "white");
                                            d3.select("body")
                                              .style("background-repeat", "no-repeat")
                                              .style("background-position", "right bottom");}')
  }### PLOT NETWORK
  
  
  ts<-ymd_hms(topic$tweet_created_at)
  interval=ceiling(as.numeric(max(ts)-min(ts)))
  p<-ggplot(topic)+geom_histogram(mapping = aes(x = ts), color='navy',bg='lightblue3', bins=interval*4*4) + 
    theme_light() + xlab('') + ylab('Frequency') + ggtitle(paste0('Menciones: ', name))
  
  ### SAVE THE TIMELINE_PLOT AND THE GRAPH
  setwd(paste0('~/R/Prueba_GrafosTFM_',format(Sys.Date(),format="%d-%m-%Y")))
  pdf(paste0(name, '_timeline.pdf'))
    print(p)
  dev.off()
  saveWidget(Network, file=paste0(name, "_grafo.html"))
  
  setwd('~')
}


