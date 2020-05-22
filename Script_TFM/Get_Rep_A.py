import botometer
import json
import twitter
import os


def cls():
    os.system('cls' if os.name=='nt' else 'clear')

def header():
    cls()
    print("")
    print(" ######## ########  ##     ##  ######  ######## ##      ##  #######  ########  ######## ##     ## ##    ## ")
    print("    ##    ##     ## ##     ## ##    ##    ##    ##  ##  ## ##     ## ##     ##    ##    ##     ##  ##  ##  ")
    print("    ##    ##     ## ##     ## ##          ##    ##  ##  ## ##     ## ##     ##    ##    ##     ##   ####   ")
    print("    ##    ########  ##     ##  ######     ##    ##  ##  ## ##     ## ########     ##    #########    ##    ")
    print("    ##    ##   ##   ##     ##       ##    ##    ##  ##  ## ##     ## ##   ##      ##    ##     ##    ##    ")
    print("    ##    ##    ##  ##     ## ##    ##    ##    ##  ##  ## ##     ## ##    ##     ##    ##     ##    ##    ")
    print("    ##    ##     ##  #######   ######     ##     ###  ###   #######  ##     ##    ##    ##     ##    ##    ")
    print("")                                                                                                       
    print(" ---------------------------------------")

def end():
    print("")
    print("  *****************************")
    print("  ****    END OF SESION    ****")
    print("  *****************************")

def show_tr(p):

    v=[(1-float(p['categories']['user'])),
      (1-float(p['categories']['content'])),
      (1-float(p['categories']['temporal'])),
      (1-float(p['categories']['sentiment'])),
      (1-float(p['cap']['universal']))] #Vector which contains the parameters

    print("  Trustworthy level:",round(100*((1-float(p['categories']['user']))*
                                            (1-float(p['categories']['content']))*
                                            (1-float(p['categories']['temporal']))*
                                            (1-float(p['categories']['sentiment']))*
                                            (1-float(p['cap']['universal'])))**(1. / 5.),2),"%")
    print("")
    print("  Summary")
    print("    - User:     ",round(100*v[0],2),"%")
    print("    - Content:  ",round(100*v[1],2),"%")
    print("    - Temporal: ",round(100*v[2],2),"%")
    print("    - Sentiment:",round(100*v[3],2),"%")
    print("    - Botometer: ",round(100*(1-v[4]),2),"%")

rapidapi_key = " " # also known as Mashape_key
twitter_app_auth = {
    'consumer_key': ' ',
    'consumer_secret': ' ',
    'access_token': ' ',
    'access_token_secret': ' ',}

bom = botometer.Botometer(wait_on_ratelimit=True,
                          rapidapi_key=rapidapi_key,
                          **twitter_app_auth)

header()
u=input("  User name: ")
print("")

while(u not in ["x","X"]):
    try:
        p = bom.check_account(u)
        show_tr(p)
    except:
        print('  There is no "',u,'" user in the Twitter DDBB.', sep='')
    print(" ---------------------------------------")
    u=input("  User name: ")
    print("")
end()
