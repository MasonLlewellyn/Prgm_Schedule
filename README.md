Original App Design Project - README Template
===

# Schedulr (Coming up with a better one)

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
This application is a "programmatic scheduler".   It's design is pretty experiemntal and weird.  When the application is opened, its appearance is like any other "notes" application, a blank canvas.  The user can type plaintext notes but the applications main feature is that it auto-detects and formats "events" and "reminders".  Scheduling is as simple as selecting which "block" either event or reminder and spevifying its fields.  Events work similarly.  The difference between events and reminders is that events have a given start and end date while reminders are simply displayed at a given instant.  

### App Evaluation
- **Category:** Scheduling/Productivity
- **Mobile:** The "programmatic" scheduler can condition events on GPS location and later, maybe other mobile-specific properties.
- **Story:** User can open the application to a blank text view (an empty schedule).  To add events, the user would type auto-completed commands such as "Event" and "Reminder".  These events would auto-suggest their required fields similar to the way XCode auto-suggests code snippets.   
- **Market:**  The whole concept of this application is pretty experimental.  It is designed as a learning experience which is probably really bad in terms of marketing. If it were to be adopted by anyone, it would be power users who would want to quickly create and manage a schedule.  
- **Habit:**  Not necessarily habit-forming but someone could get used to checking it every morning.
- **Scope:**  I think that even an MVP for this application would be interesting to build.   

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User opens application to blank text view
* User can save individual notes and access them later
* Users text is augmented with suggestion when they type words such as "reminder" or "event"
* An auto-suggested and filled event is added to calenders or reminders
* Add invitees to calender events
* Evens and reminders can be conditioned on wather
* Events and reminders sends push notifications to user

**Optional Nice-to-have Stories**

* Events are highlighted to indicate if they are "on" or "off"
* Events are conditioned on other events the relationship is also highlighted.
* Add additional conditions for events
* Potentially add additional time/place activated actions such as:
    * When I'm at the park before noon, suggest opening spotify to my workout playlist.  
* ...

### 2. Screen Archetypes

* [list first screen here]
   * [list associated required story here]
   * ...
* [list second screen here]
   * [list associated required story here]
   * ...

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* [fill out your first tab]
* [fill out your second tab]
* [fill out your third tab]

**Flow Navigation** (Screen to Screen)
* [list first screen here]
   * [list screen navigation here]
   * ...
* [list second screen here]
   * [list screen navigation here]
   * ...

## Wireframes
[Add picture of your hand sketched wireframes in this section]
<img src="YOUR_WIREFRAME_IMAGE_URL" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
[This section will be completed in Unit 9]
### Models
Class WeatherObj: Subclass Event
        1. String Description
        2. Int temperature
        3. Enum Condition {SUNNY, CLOUDY, PARTLY_CLOUDY}
        4. Int desiredTemp
        5. Int desiredCond
    2. Class: Event
        1. String Title
        2. NSDate startDateTime
        3. NSDate endDateTime
        4. String LocationName
        5. Int locationLat
        6. Int locationLong
        7. Object: Depends
        8. Boolean isActive
    3. Class: Reminder SubClass Event
        1. //Not exactly sure what attributes this class wold have
    4. Class Action: SubClass Event
        1. //Also not sure how this will work maybe I’ll only support certain actions
        2. App openApp
        3. Args openAppArgs
        4. Enum actionKind {openSpotify, chartRoute, sendText}
### Networking
