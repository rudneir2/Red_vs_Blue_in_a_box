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

The diagrams below explain how we prepared the solution for the Red vs Blue scenario.

![image](https://user-images.githubusercontent.com/97529152/157371437-d895f13c-8a25-42e4-94fe-1367f3028ca2.png)

The second diagram below is just an example of an attacks against the Web App, however with two layers of protection, the WAF and Microsoft Sentinel. 

![image](https://user-images.githubusercontent.com/97529152/157371801-bf7de26a-c5c3-4313-8f4c-eaad0321caaf.png)

More details about each type of attack (Red Team) and the Azure Security services that will provide protection to the environment (Blue Team), will be in separated articles (links below).

## The Box

This entire environment may be deployed automatically through an ARM Template through this **<link>**. That is what is referred to in the title of this article as "a box", which means, everything together, in a single “box”, to make easier the deployment of the environment so that you may focus on the Security part of the exercise and play both Red and Blue team.

If you try to use a Microsoft or a MSDN Azure subscription, you will have to use this ARM Template that contains a version of Kali Linux that is allowed to be deployed on Microsoft or MSDN subscriptions.
<link>

This ARM Template will require some additional steps to make Kali Linux work properly. Those steps are part of the document in the link above.

Both ARM Templates above will be available soon on a **Biceps** version as well.
