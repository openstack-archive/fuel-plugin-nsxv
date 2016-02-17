================================
Test Plan for NSXv plugin v2.0.0
================================

************
Introduction
************

Purpose
=======

Main purpose of this document is intended to describe Quality Assurance
activities, required to insure that Fuel plugin for VMware NSXv driver is
ready for production. The project will be able to offer VMware NSXv
integration functionality with MOS. The scope of this plan defines the
following objectives:

* Identify testing activities;
* Outline testing approach, test types, test cycle that will be used;
* List of metrics and deliverable elements;
* List of items for testing and out of testing scope;
* Detect exit criteria in testing purposes;
* Describe test environment.

Scope
=====

Fuel NSXv plugin includes NSX plugin for Neutron which is developed by
third party. This test plan covers a full functionality of Fuel NSXv plugin,
include basic scenarios related with NSXv Neutron plugin.

Following test types should be provided:

* Smoke/BVT tests
* Integration tests
* System tests
* Destructive tests
* GUI tests

Performance testing will be executed on the scale lab and a custom set of
rally scenarios must be run with NSXv environment. Configuration, environment
and scenarios for performance/scale testing should be determine separately.

Intended Audience
=================

This document is intended for project team staff (QA and Dev engineers and
managers) and all other persons who are interested in testing results.

Limitation
==========

Plugin (or its components) has the following limitations:

* VMware NSXv plugin can be enabled only with Neutron tunnel segmentation.
* Environment with enabled VMware NSXv plugin can't contains compute nodes.
* Only VMware NSX Manager Virtual Appliance 6.1.4 or later is supported.

Product compatibility matrix
============================

.. list-table:: product compatibility matrix
   :widths: 15 10 30
   :header-rows: 1

   * - Requirement
     - Version
     - Comment
   * - MOS
     - 8.0
     -
   * - OpenStack release
     - Liberty with Ubuntu 14.04
     -
   * - vSphere
     - 5.5 and 6.0
     -
   * - NSXv
     - 6.2.0 and 6.1.4 (not tested)
     - 

**************************************
Evaluation Mission and Test Motivation
**************************************

Project main goal is to build a MOS plugin that integrates a Neutron VMware
NSX plugin. This will allow to use Neutron for networking in vmware-related
environments. The plugin must be compatible with the version 8.0 of Mirantis
OpenStack and should be tested with software/hardware described in
`product compatibility matrix`_.

See the VMware NSX Plugin specification for more details.

Evaluation mission
==================

* Find important problems with integration of Neutron VMware NSX plugin.
* Verify a specification.
* Provide tests for maintenance update.
* Lab environment deployment.
* Deploy MOS with developed plugin installed.
* Create and run specific tests for plugin/deployment.
* Documentation.

*************
Test approach
*************

The project test approach consists of Smoke, Integration, System, Regression
Failover and Acceptance test levels.

**Smoke testing**

The goal of smoke testing is to ensure that the most critical features of Fuel
VMware NSXv plugin work after new build delivery. Smoke tests will be used by
QA to accept software builds from Development team.

**Integration and System testing**

The goal of integration and system testing is to ensure that new or modified
components of Fuel and MOS work effectively with Fuel VMware NSXv plugin
without gaps in data flow.

**Regression testing**

The goal of regression testing is to verify that key features of Fuel VMware
NSXv plugin are not affected by any changes performed during preparation to
release (includes defects fixing, new features introduction and possible
updates).

**Failover testing**

Failover and recovery testing ensures that the target-of-test can successfully
failover and recover from a variety of hardware, software, or network
malfunctions with undue loss of data or data integrity.

**Acceptance testing**

The goal of acceptance testing is to ensure that Fuel VMware NSXv plugin has
reached a level of stability that meets requirements and acceptance criteria.


***********************
Entry and exit criteria
***********************

Criteria for test process starting
==================================

Before test process can be started it is needed to make some preparation
actions - to execute important preconditions. The following steps must be
executed successfully for starting test phase:

* all project requirements are reviewed and confirmed;
* implementation of testing features has finished (a new build is ready for testing);
* implementation code is stored in GIT;
* test environment is prepared with correct configuration, installed all needed software, hardware;
* test environment contains the last delivered build for testing;
* test plan is ready and confirmed internally;
* implementation of manual tests and autotests (if any) has finished.

Feature exit criteria
=====================

Testing of a feature can be finished when:

* All planned tests (prepared before) for the feature are executed; no defects are found during this run;
* All planned tests for the feature are executed; defects found during this run are verified or confirmed to be acceptable (known issues);
* The time for testing of that feature according to the project plan has run out and Project Manager confirms that no changes to the schedule are possible.

Suspension and resumption criteria
==================================

Testing of a particular feature is suspended if there is a blocking issue
which prevents
tests execution. Blocking issue can be one of the following:

* Testing environment for the feature is not ready
* Testing environment is unavailable due to failure
* Feature has a blocking defect, which prevents further usage of this feature and there is no workaround available
* CI tests fail

************
Deliverables
************

List of deliverables
====================

Project testing activities are to be resulted in the following reporting documents:

* Test plan
* Test report
* Automated test cases

Acceptance criteria
===================

* All acceptance criteria for user stories are met.
* All test cases are executed. BVT tests are passed
* Critical and high issues are fixed
* All required documents are delivered
* Release notes including a report on the known errors of that release
