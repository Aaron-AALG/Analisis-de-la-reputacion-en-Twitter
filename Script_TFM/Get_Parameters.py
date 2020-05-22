import botometer
import json
import sys
import time

rapidapi_key = " "  
twitter_app_auth = {
    'consumer_key': ' ',
    'consumer_secret': ' ',
    'access_token': ' ',
    'access_token_secret': ' ',
  }

bom = botometer.Botometer(wait_on_ratelimit=True,
                          rapidapi_key=rapidapi_key,
                          **twitter_app_auth)

v=input('Twitter username: ')

for file in v:
  
  print('')
  print('----------------------------------------------------')
  print('  Start:', file, ':', time.asctime())
  print('----------------------------------------------------')

  u_file= open(str(file +'_friends.txt'),'r')
  user=u_file.readlines()
  u_file.close()

  p_file= open(str('rep_'+ file +'_friends.txt'),"a")
  p_file.write('{'+'\n')
  p_file.write('"elementlist" :[' +'\n')
  
  n=int(len(user)-2)
  for u in user[0:n]: 
    try:
      p = json.dumps(bom.check_account(u), ensure_ascii=False)
      p_file.write(str(p) + ','+'\n')
      print(u +'\n')

    except:      #tweepy.error.TweepError
      print(" *** ERROR with: " + u )

  p = json.dumps(bom.check_account(user[n+1]), ensure_ascii=False)
  p_file.write(str(p) +'\n')
  p_file.write("]"+'\n')
  p_file.write("}"+'\n')
  p_file.close

  print('----------------------------------------------------')
  print('  End:', file, ':', time.asctime())
  print('----------------------------------------------------')
  print('')

for file in v:
  
  print('')
  print('----------------------------------------------------')
  print('  Start:', file, ':', time.asctime())
  print('----------------------------------------------------')

  u_file= open(str(file +'_followers.txt'),'r')
  user=u_file.readlines()
  u_file.close()

  p_file= open(str('rep_'+ file +'_followers.txt'),"a")
  p_file.write('{'+'\n')
  p_file.write('"elementlist" :[' +'\n')
  
  n=int(len(user)-2)
  for u in user[0:n]: 
    try:
      p = json.dumps(bom.check_account(u), ensure_ascii=False)
      p_file.write(str(p) + ','+'\n')
      print(u +'\n')

    except:      #tweepy.error.TweepError
      print(" *** ERROR with: " + u )

  p = json.dumps(bom.check_account(user[n+1]), ensure_ascii=False)
  p_file.write(str(p) +'\n')
  p_file.write("]"+'\n')
  p_file.write("}"+'\n')
  p_file.close

  print('----------------------------------------------------')
  print('  End:', file, ':', time.asctime())
  print('----------------------------------------------------')
  print('')