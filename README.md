# Red vs Blue in a box
FTA hackathon March 2022 (done by Rudnei, Andre, Ricardo, Simona, Andrew and Andrej)

## Intro

In the Cybersecurity area, it is very common Security professionals refer to “Red Team” and “Blue Team”, when they want to specify in each side that Team are playing. Red means “attack” and Blue means “defense”.

**Red team** plays in the offensive side, and they will work to try compromising their own environment with different cybersecurity tools like many available through a Kali Linux distribution.

**Blue team** works on the defense against Red team and they are supposed to test the effectiveness of their security solutions.

This is a great scenario for a Microsoft hackathon exercise.

As a Red team will have a Kali Linux VM as the main tool to attack. As a Blue team will have some Azure security services to protect a simple environment that contains a Web App solution and two VMs, one with Windows 10 and one with Windows Server 2019. Those are the Security service that Blue team may work with:

-	Azure Firewall
-	DDOS protection
-	Web Application Firewall
-	Log Analytics (log repository)
-	Sentinel (SIEM / SOAR)

## Scenario with no Azure Security service
The diagrams below explain how we prepared the solution for the Red vs Blue scenario.

![image](https://user-images.githubusercontent.com/97529152/157374253-d4e03fc9-6dcb-483a-b5c4-86eae951cb2f.png)

**NOTE:**
The Kali Linux may be deploy in different ways, it will depend on your internal Security policies and rules. Those are some options you can consider:
- everything on the same subscription and the same resorce group;
- kali linux in a different resource group
- kali linux in a different subscription 
* *(this is how we did it! Kali on a private subscription and the rest of the environment on a Microsoft subscription)* *

## Scenario WITH Azure Security service
The second diagram below is just an example of an attacks against the Web App, however with two layers of protection, the WAF and Microsoft Sentinel.

![image](https://user-images.githubusercontent.com/97529152/157374378-cefbb1fa-9eb9-491f-8b28-9452dd798c95.png)

More details about each type of attack (Red Team) and the Azure Security services that will provide protection to the environment (Blue Team), will be in separated articles (links below).

## The Box

This entire environment may be deployed automatically through an ARM Template through this **RICARDO LINK**. That is what is referred to in the title of this article as "a box", which means, everything together, in a single “box”, to make easier the deployment of the environment so that you may focus on the Security part of the exercise and play both Red and Blue team.

If you try to use a Microsoft or a MSDN Azure subscription, you will have to use this ARM Template that contains a version of Kali Linux that is allowed to be deployed on Microsoft or MSDN subscriptions.
**RICARDO LINK**

This **ARM Template** will require some additional steps to make Kali Linux work properly. Those steps are part of the document in the link above.

Both ARM Templates above will be available soon on a **Biceps** version as well. **ANDREJ**

## Red Team - the Attacks

This environment considers simulation with the following attacks:
1.	Web vulnerability scan (https://github.com/rudneir2/attack-web_vulnerability_scan)
2.	XSS (Cross-site scripting) **link**
3.	SQLi **link**
4.	AndreAttack **link**
5.	AndreAttack **link**
6.	SimonaAttack **link**
7.	SimonaAttack **link**

## How to execute the Attacks

So, once you deploy the environment through the ARM template or manually, resource by resource, in case you prefer, you can start playing with both sides, the attacks and the defense.
These is the prerequisites to deploy the environment and play with Red and Blue solutions:
-	An Azure subscription
-	A basic knowledge about ARM Template deployment
-	An intermediate knowledge about Azure deployment in case you decide to deploy it manually, as this will require you to plan and deploy multiple resources
Each attack listed above has its own playbook with instructions on how to start it and how to use the Azure security services to avoid or mitigate the attack.



