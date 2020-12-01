# Project Collection and Assignment (Fall 2020)

This is a fork of "Project Collection and Assignment" from https://github.com/harishk1908/Project_Collection_and_Assignment.

Heroku Link     - https://pro-assign.herokuapp.com/

This project is a part of CSCE 685 Directed Studies. The main customer of the application is the course instructor for CSCE 606 - Prof. Duncan M. (Hank) Walker, the teaching assistant for the course in the following semesters, and the student taking the course. The updated version is deployed on Heroku account and the source code can be found on the Github link mentioned above.

Objective
===================

 - Manage Team formation between students
 - Filling project preference by the Team leader
 - Assign projects to the team based on the preferences filled by the team
 - Migration of projects from one semester to the next semester.
 - Downloading the student records and project assignment records.
 - Allow admins to modify team and project information.

Features Implemented
===================

 - Sorting of student records based on the last name is implemented. Previously, the sorting was based on the first name of the user only. This is only visible from the admin view and on the All users page.
 - The name "View Assignment" is changed to "View/Make Assignments". This can be found in the header view.
 - Changes are made in the assignment_controller to list only approved projects in the View Assignments page. Previously, all the projects were displayed in the assignment dropdown box.
 - After the migration, the status of the migrated projects is set to "Not approved". Previously, the status of project was not changed. Now, after the migration of the projects to the next semester, the admin must approve the projects for the next semesters. Only these approved projects will be visible to the students and the students can fill out their preferences from these approved projects.
 - Peer evaluation content is deleted from the application. Peer Evaluation will be handled in Canvas.
 - Added a check to migrate only active projects to the next semester. Archived project are not migrated. To migrate a archived project, the project need to be unarchived from the All Projects page and then the migration should be initiated.
 - Since Pivotal and Heroku links will not be used in the future, they are removed. Only Github link is present. Moreover, the documentation link is also removed. The Documentation should be done in Github repository Readme.
 - The forget password functionality was already implemented. An account is created on SendGrid and a single sender is created with “walker@cse.tamu.edu” . The emails will be received from this email id. Moreover, the SENDGRID_API_KEY is added to the environment variables in Heroku. Also, the “From” mail is updated in application_mailer to Prof. Walker’s email. This will be the Id in From field when password reset email is received.
 - The Project is deployed on pro-assign.heroku.com.
 - An additional backup of the app is created on pro-assign-backup.heroku.com. This is the pervious version of the application used for Fall 2020 and previous semesters. This also contains the backup of all the projects data. 

User Stories
===================

The following are the user stories for the tasks above. The user stories are improvements over the stories in the previous course semester.

 - As an Admin, I want to sort the student using the first and last name, so that I can find the student records easily.
 - As an Admin, I want to allow on approved projects to be seen by the student, so that the student can fill out their preferences.
 - As an Admin, I want to migrate the current semester projects to the next semester, so that I can use the existing information and make necessary changes.
 - As an admin, I want all the migrated projects to be set to “Not approved”, so that I can select which projects to include in the current semester.
 - As an Admin, I want only the unarchived projects to be migrated to the next semester, so that legacy projects are not edited.
 - As an Admin, I want to add/edit/remove admins, so that I can delegate duties to other admins.
 - As an Admin/Student, I want to reset my password, so that I can set a new password when I forget my Password.
 - As an Admin, I want to see project selection of each team, so that I can communicate with each team on the assigned project.
 - As an admin, I want to download data for all students and project for the current semester, so that I can keep a copy of the semester data for future use.