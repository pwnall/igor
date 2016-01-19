# Site Administrator and Staff Guide

## Table of Contents

- [Site Initialization](#admin-duties)
  - [Configure the SMTP server](#smtp-server)
  - [Delete unverified accounts](#sketchy-accounts)
  - [Add an e-mail resolver](#email-resolver)
  - [Configure a new course](#new-course)
  - [Approve staff request](#staff-requests)
- [Staff Registration](#registration)
- [Basic Course Settings](#course-settings)
- [Prerequisites](#prerequisites)
- [Recitation Sections](#recitations)
  - [Add time slots](#time-slots)
  - [Add recitation sections](#new-recitation)
  - [Generate assignment proposals](#new-proposal)
  - [Choose an assignment proposal](#choose-proposal)
- [Homework Assignments](#assignments)
  - [PDF deliverables](#pdf-deliverables)
  - [Code deliverables](#code-deliverables)
- [Exams](#exams)
  - [Student check-ins and staff confirmation](#check-in)
- [User Visibility and Permissions](#visibility-permissions)
- [Deadline Extensions](#extensions)

This guide will run through the basic setup needed to kick off a new course on
a freshly deployed app. If you can, follow along with the site open.
Instructions for setting up your own test instance are [here](deployment.md).
The first step is to create a site admin account.

## <a name="admin-section"></a>Site Initialization

On fresh deployments, the first user to register will automatically be granted
site administrator permissions. When logged in, site admins will have access to
the _Admin_ menu, which allows them to create and configure new courses, e-mail
resolvers, and SMTP servers.

### <a name="smtp-server"></a>1. Configure an SMTP server

It is very important that the site admin set up the SMTP server first, before
configuring any other parts of the site, to ensure that all user accounts have
valid e-mail addresses. This step will require new users to respond to a
verification e-mail in order to be marked as _verified_. Until the SMTP server
is configured, all newly created user accounts will be automatically marked as
_verified_ and be free to roam the site, whether or not they have registered a
legitimate e-mail address.

The necessary SMTP server credentials for MIT are below:

| Option Name    | Option Value     |
| -------------- | ---------------- |
| Hostname       | outgoing.mit.edu |
| Port           | 25               |
| HELO Domain    | mit.edu          |
| Authentication | None             |
| Username       | _(leave blank)_  |
| Password       | _(leave blank)_  |

### <a name="sketchy-accounts"></a>2. Delete sketchy user accounts

Remember how any user accounts created before you set up the SMTP server are
able to bypass e-mail verification? The next step is to check whether any such
accounts have been created, and remove them. Go to _Admin_ > _Site Users_ to
view the site users directory, and remove any accounts other than yours (the
site admin) and the staff robot's.

**NOTE**: DO NOT DELETE THE STAFF ROBOT'S USER ACCOUNT. The staff robot is
responsible for the site's auto-grading feature, so deleting the robot will
break auto-grading. There is currently no way to recreate a robot account.

### <a name="email-resolver"></a>3. Add an e-mail resolver

At this point, you can begin creating courses and using all of the site's
features. Before moving onward, however, you can create an e-mail resolver to
enable auto-completion for users filling out a new profile form in the future.

The setup options for MIT are below:

| Option Name               | Option Value                    |
| ------------------------- | ------------------------------- |
| Domain                    | mit.edu                         |
| LDAP Server               | ldap.mit.edu                    |
| Use LDAPS                 | _(checked)_                     |
| LDAP Auth DN              | _(leave blank)_                 |
| LDAP Password             | _(leave blank)_                 |
| LDAP Search Base DN       | ou=users,ou=moira,dc=mit,dc=edu |
| Full Name LDAP Attribute  | displayName                     |
| Department LDAP Attribute | ou                              |
| Year LDAP Attribute       | mitDirStudentYear               |
| Username LDAP Attribute   | uid                             |

### <a name="new-course"></a>4. Add a new course

Staff members can configure courses, but cannot create them. Thus, the site
admin should create a new course for which staff members can register. The site
admin should not need to anguish over the course's basic settings, as that is
the responsibility of the course's staff members.

### <a name="staff-requests"></a>5. Approve a staff role request

For instructors (professors and TAs) or graders to be granted their respective
roles, they must be approved by someone with an equivalent or higher permissions
level. The hierarchy of site permissions is listed below:

1. Site administrator (can do almost anything)
2. Course instructors
3. Course graders
4. Course students
5. Unregistered users (can do very little)

As such, the very first instructor/grader will need to be approved by the site
admin. From then onward, instructors/graders can approve one another. To approve
a staff request as the admin, go to _Admin_ > _Courses_ and enter the course of
interest. A bunch of course-specific menu items should appear on the left. Go to
_Course_ > _Staff_ and click on the _Pending Staff Registrations_ tab.

**Note**: You may have noticed that on the site admin's account, the
_Impersonate_ button sometimes appears beside a username. This feature allows
the site admin to see exactly what another user sees, and thus debug site issues
with ease. It is an extremely powerful feature, and should be used with care.

## <a name="course-settings"></a>Staff Registration

As an existing staff member, you can approve staff role requests as more staff
members register for the course. To do so, go to _Course_ > _Staff_ and click on
the _Pending Staff Registrations_ tab. There, you should see all the staff
requests, and buttons for approving or denying them. The users you approve
should then be able to follow the same instructions for approving staff requests
in the future.

**Note**: If you register as a staff member for a course, DO NOT also register
as a student for that course.

**Tip**: As you configure your course, you will find that some modifications
affect the student registration form. If you are curious to see exactly how the
registrations form renders under your configuration, you can create another
"fake" account by appending a tag to your e-mail address to view the
registration form. For example, if your e-mail address is _user@domain.edu_, you
can create a second account under the e-mail address _user+test123@domain.edu_.
E-mails for this account will still get routed to your inbox! You should not
actually submit the registration form under this "fake" account, and only the
staff member responsible for configuring the course should need to use this
trick.

## <a name="course-settings"></a>Basic Course Settings

Courses come with a few optional features, detailed below:

- **Staff request e-mails**: Check this box if you want to send an e-mail to the
    staff e-mail address every time a user requests to be a staff member for
    this course. If you do not check this option, then you will need an
    alternative means of alerting staff members when there are pending staff
    role requests.
- **Recitation sections**: Check this box if you want to enable recitation
    sections. Be sure to specify a section size! Setting up recitation sections
    is described [below](#recitations).
- **Surveys**: Check this box if you want to create surveys. Enabling this
    feature will activate the _Course_ > _Surveys_ staff-only menu item.
    **Note**: In the future, this feature will be enabled by default.
- **Homework teams**: This feature is currently under construction, has
    [known issues](https://github.com/pwnall/seven/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+team),
    and should not be used in production.

## <a name="prerequisites"></a>Prerequisites

In order to assess the experience levels of incoming students, you can add
prerequisite questions, which will appear on the student registration form. To
view/add prerequisite questions, go to _Course_ > _Prerequisites_.

## <a name="recitations"></a>Recitation Sections

Enabling **Recitation sections** for a course will activate two staff-only menu
items under the _Course_ menu: _Time Slots_ and _Recitations_. It will also
activate an availability section in the student registration form, that will
gather data on potential scheduling conflicts in order to find the best
recitation section assignments.

### <a name="time-slots"></a>1. Add time slots

A recitation section must take place at certain times, so we must first specify
those times before we can create any recitation sections. Go to _Course_ >
_Time Slots_, and add all of the possible time slot options for a recitation
section to take place. These options will appear in the student registration
form, and students will mark which of these conflict with their other classes.
Thus, it is advised to complete this step before students begin registering, if
you plan on using recitation sections.

### <a name="new-recitation"></a>2. Create recitation sections

Now you can go to _Course_ > _Recitations_ and create recitation sections. You
should be able to pick from the time slot options you specified in step 1 above.

### <a name="new-proposal"></a>3. Generate assignment proposals

After creating all the recitation sections, you are ready to assign students to
those sections. From _Course_ > _Recitations_, click _All Section Assignments_
to view your list of potential student-recitation matchings. If you don't have
any, click _Generate New Proposal_ to create one. If you don't like the proposed
assignment map, you can tweak your parameters, such as the recitation section
size, and try again.

### <a name="choose-proposal"></a>4. Choose an assignment proposal

Once you generate a recitation assignment proposal that you like, you can select
it by opening it, and clicking the _Implement!_ button.

## <a name="assignments"></a>Homework Assignments

To create a new assignment, open the _Assigments_ menu, and click the _Add
Assignment_ menu item. On the assignment builder form, leave the **Enable Exam
Features** switch turned off. After you submit this basic form, you will be able
to define this assignment's deliverables (**Files to be Submitted**), upload
resource files, and specify the grading breakdown.

### <a name="pdf-deliverables"></a>PDF deliverables

If you'd like students to submit a PDF for this assignment, select the
**Built-in Analyzer** option under **Files to be Submitted**. The
**PDF Analyzer** is currently the only built-in analyzer we support.

### <a name="code-deliverables"></a>Code deliverables

If you'd like students to submit code for this assignment, select the **Docker
Analyzer** option under **Files to be Submitted**. In order to evaluate student
code submissions, you will need to write custom analyzer scripts for this
assignment and upload them in this section. For more instructions on how to
write and package your scripts, click on the blue _i_ button to the left of the
file upload field.

The student time limit (and RAM limit, etc) apply to the student's code, as it
processes one test case. Each test case is processed independently, so if you
have 40 test cases and a time limit of 30 seconds, you could find the server
spending 20 minutes (1200 seconds) to grade a single submission. Asides from
keeping the server available, the student time limits can help you separate
inefficient solutions from good ones.

The grader limits apply when the site runs your grading code to determine a
submission's score, based on its outputs for all the test cases. The limits are
intended to protect you from student code that hits bugs in your grader. For
example, if your grader happens to get stuck an infinite loop when reading some
degenerate student output, the server will terminate it after it hits the grader
time limit. The grader limits aren't supposed to test your grader's efficiency,
so you can be quite generous here.

## <a name="exams"></a>Exams

To create a new exam, open the _Assigments_ menu, and click the _Add Assignment_
menu item. On the assignment builder form, flip on the **Enable Exam Features**
switch. Flipping this switch will activate the _Exam Sessions_ section of the
form, where you can specify the times and locations at which this exam will be
administered.

### <a name="check-in"></a>Student Check-ins and Staff Confirmation

After the release date of this exam passes, students will be able to check in to
an exam session of their choice. Staff members can view the check-in roster for
each exam session by visiting the _Exam Sessions_ tab on the exam's dashboard,
and clicking the _View Roster_ button for a session.

If you checked the **Session Attendance** option that requires students to be
checked-in by a staff member before they can take the exam during their selected
session, you can confirm student check-ins through the check-in roster. If you
did not check that option, then student check-ins will be automatically
confirmed.

Once a student's check-in to an exam session is confirmed, they will be able to
view and upload submissions for the exam throughout the duration of their
session.

## <a name="visibility-permissions"></a>User Visibility and Permissions

It is very important to be aware of exactly what students can see vs. what staff
members can see. Below are some concepts to help you determine user visibility
at any time.

Course instructors can always see everything related to the course. This
includes all the draft assignments and all the files/resources connected to
them. Another way to look at this is that we assume that the instructors are
working together as a team, so we don't have any barriers in place between them.
**All instructors have exactly the same view of the course data.**

We do have barriers between students and instructors, for obvious reasons.
Releasing an assignment lifts this barrier for that assignment. Individual files
(resources) associated with an assignment/exam have their own release dates, so
you can, for example, upload the solutions to an assignment, and only allow
students to access it on a specific date well after the deadline has passed.
Publishing the schedule of an assignment or exam is meant to let students mark
the due date in their calendars, without giving them access to any other aspects
of the assignment/exam.

At any point, you can use the _Hide everything_ button as an escape hatch to
completely remove student visibility for that assigment/exam.

## <a name="extensions"></a>Deadline Extensions

To grant a student a deadline extension on a homework assignment or an exam, go
to that assignment's/exam's dashboard, and click on the _Extensions_ tab. The
_Grant Extensions_ button should pull up the list of extensions granted for this
assignment/exam, and show a form for granting a new extension.
