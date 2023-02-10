

<!--
The following template is based on:
Best-README-Template
Search for this, and you will find!
>
<!-- PROJECT LOGO -->
<br />
<p align="center">
  <!-- <a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a> -->

  <h2 align="center"> TrafficSimulators_WideAreaCoordinateSystems
  </h2>

<img src=".\Images\CompassImage_small.jpg" alt="compass in front of mountains" width="960" height="540">

<font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font>

  

# Wide Area Coordinate Systems

  <p align="center">
  This repo presents the coordinate systems for describing a point on the surface of the earth, it compares the accuracy of various calculations using these coordinate systems, and it provides the rationale for choosing a specified sequence of these coordinate systems (with the associated transformations). This code was originally developed in support of the simulation environment built for the NSF CPS “Forgetful Databases” project. 
    <br />
    <a href="https://github.com/ivsg-psu/TrafficSimulators_WideAreaCoordinateSystems/tree/main/Documents"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <!-- a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/tree/main/Documents">View Demo</a -->
    ·
    <a href="https://github.com/ivsg-psu/TrafficSimulators_WideAreaCoordinateSystems/issues">Report Bug</a>
    ·
    <a href="https://github.com/ivsg-psu/TrafficSimulators_WideAreaCoordinateSystems/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#Introduction">Introduction</a>
        <ul>
          <li><a href="#some-definitions">Some Definitions</a></li>
        </ul>
    </li>
    <li>
      <a href="#coordinate-conventions">Coordinate Conventions</a>
      <ul>
          <li><a href="#spherical-coordinates">Spherical Coordinates</a></li>
          <li><a href="#lla-coordinates">LLA Coordinates</a></li>
          <ul>
            <li><a href="#wgs84-geodetic-datum">WGS84 Geodetic Datum</a></li>
          </ul>          
          <li><a href="#ll-coordinates">LL Coordinates</a></li>
          <li><a href="#ecef-coordinates">ECEF Coordinates</a></li>
          <li><a href="#enu-coordinates">ENU Coordinates</a></li>
          <li><a href="#utm-coordinates">UTM Coordinates</a></li>
          <li><a href="#sth-coordinates">STH Coordinates</a></li>
      </ul>
    </li>    
    <li>
      <a href="#error-analysis">Error Analysis</a>
      <ul>
          <li><a href="#distance-metrics">Distance Metrics</a></li>
          <ul>
            <li><a href="#euclidean-distance">Euclidean distance</a></li>
            <li><a href="#geodesic-distance">Geodesic distance</a></li>
            <li><a href="#station-distance">Station distance</a></li>
          </ul>          
          <li><a href="#direct-conversion-errors">Direct Conversion Errors</a></li>
          <ul>
            <li><a href="#geodetic-vs-utm-distance-errors-with-matched-station">Geodetic vs UTM Distance Errors with Matched Station</a></li>
            <li><a href="#geodesic-distance">Geodesic distance</a></li>
            <li><a href="#station-distance">Station distance</a></li>
          </ul>                    
          <li><a href="#ll-coordinates">LL Coordinates</a></li>
          <li><a href="#ecef-coordinates">ECEF Coordinates</a></li>
          <li><a href="#enu-coordinates">ENU Coordinates</a></li>
          <li><a href="#utm-coordinates">UTM Coordinates</a></li>
          <li><a href="#sth-coordinates">STH Coordinates</a></li>
      </ul>
    </li>
    <li><a href="#installation">Installation</a>
	    <ul>
	      <li><a href="#steps">Steps</li>
	      <li><a href="#directories">Top-Level Directories</li>
	      <li><a href="#dependencies">Dependencies</li>
	      <li><a href="#functions">Functions</li>
	      <li><a href="#examples">Examples</li>
	    </ul>
    </li>
    <li><a href="#useful-references">Useful References</a></li>
	    <ul>
      <li><a href="precision-chart-for-gps">Precision chart for GPS</li>
	    <li><a href="#definition-of-endpoints">Definition of Endpoints</li>
	    </ul>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

<a href="#wide-area-coordinate-systems">Back to top</a>

<!-- INTRODUCTION -->
# Introduction
For nearly every project within the Intelligent Vehicles and Systems Group (IVSG), GPS data is a key means of obtaining measurements. Such data is usually reported in Latitude Longitude Altitude (LLA) coordiantes to position the measurement relative to the Earth's sphere. However, the use of LLA coordinates is difficult for humans and for algorithms. For humans, the numbers produced by GPS are not intuitive to clear understanding because the required precision in measurement - often 6 decimals or more - makes data entry difficult to process on single-precision variables. Further, the number of digits make data prone to human entry errors, and after entry, it is difficult to spot errors. For algorithms, the situation is also difficult: the LLA coordinate sytem itself is not isometric ("length preserving"). For example, a degree of latitude - due to the original definition of the meter as 1/10,000,000th the distance from the equator to the north pole - always corresponds to (10^7/90) or approximately 111,111 meters. However, a degree of longitude is this distance ONLY around the equator. At the north pole, a degree of longitude corresonds to zero meters. Thus, longitude degrees change in "length" by a factor of 100,000, and a steering controller based on LLA values could then have catastrophically different behaviors depending on the latitude of the vehicle! 

Unfortunately, there is not an agreed-upon "best" coordinate system to use, and as a result different tool sets use different coordinate systems. For example:

* Traffic simulation tools (SUMO for example) tend to use UTM coordinates

* 3D modeling simulation tools (CARLA, for example) tend to use ENU coordinates

* Mapping systems tend to use LLA coordinates

* Open Street Maps uses only LL coordinates (e.g., LLA without altitude)

Thus, there is a need for clear understanding of converstions between coordinate systems, and the advantages/disadvantages of different coordinate system choices. Each coordinate system choice has flaws, particularly because the representation of roadways typically assumes a locally "flat" surface which is fundamentally incompatible with the bulk shape of the planet. Thus, as the scale of a local area becomes large enough, to where the planet's sphere becomes a factor, the errors between a flat approximation versus a spherical approximation begin to grow and can become so pronounced. One result: depending on the coordinate system used, equivalent data can disagree depending on the origin and coordinate system conventions. When operating vehicles over a "large" area, for example tens to hundreds of kilometers, these errors can be so large that one cannot tell, on the "edge" of a mapped region, which lane or which road a vehicle is operating in - even though the so-called precision of the GPS measurement is reporting centimeter-level accuracy!

For a more practical example, a common challenge in traffic simulations is to correlate road properties stored in a grid with the vehicle trajectories on the road. In particular, the distance measured in one coordinate system from one point to another often is quite different than the distance in a different coordinate system for the same two points, and thus the road grid row/column index is different, depending on the choice of coordinates!

This repo demonstrates and explains some of these issues. Note: a companian repository, https://github.com/ivsg-psu/FieldDataCollection_GPSRelatedCodes_GPSClass, is available to assist specifically in performing large the coordinate systems for GPS data, including East-North-Up (ENU), Latitude-Longitude-Altitude (LLA) and Earth-Centered-Earth-Fixed (ECEF) systems. 

For a fun introduction to some of these ideas, see [the VSauce video on "How much of the earth can you see at once?"](https://www.youtube.com/watch?v=mxhxL1LzKww&list=PL5rhvP-RbZRchWj2rm7T6OEagC7UIuQLa&index=3&ab_channel=Vsauce)


<a href="#wide-area-coordinate-systems">Back to top</a>

### Some Definitions
Most of the coordinate systems described below follow the Open Geospatial Consortium definitions of common Spatial Reference Systems. 
* A spatial reference system (SRS) or coordinate reference system (CRS) is a coordinate-based local, regional or global system used to locate geographical entities.
* A spatial reference system defines a specific map projection, as well as transformations between different spatial reference systems. 
* OGC partitions SRS between Geodetic, Geocentric, Cartesian, and Local Vertical Spatial Reference Systems
* Spatial reference systems are defined by the [OGC](https://en.wikipedia.org/wiki/Open_Geospatial_Consortium)'s Simple Feature Access using well-known text(WKT) representation of coordinate reference systems, and support has been implemented by several standards-based geographic information systems. See also: [Volume 8: OGC CDB Spatial Reference System Guidance (Best Practice)]( https://docs.ogc.org/bp/16-011r5.html)

<a href="#wide-area-coordinate-systems">Back to top</a>

<!-- COORDINATE CONVENTIONS -->
# Coordinate Conventions

## Spherical Coordinates
 A spherical coordinate system is a coordinate system for 3D space where the position of a point is specified by three numbers: the radial distance (r) of that point from a fixed origin, its polar angle (&phi;) measured from a fixed zenith direction, and the azimuthal angle (&theta;) of its orthogonal projection on a reference plane that passes through the origin and is orthogonal to the zenith, measured from a fixed reference direction on that plane. Because the Earth is not a true sphere, spherical coordinates are rarely used outside of orbital maneuvers.

<pre align="center">
 <p align="center">
<img src=".\Images\SphericalCoordinates_whiteFill.png " alt="spherical coordinates" width="267" height="267">
<figcaption>Fig.1 - Spherical coordinates.</figcaption>
</p>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

<a href="#wide-area-coordinate-systems">Back to top</a>

## LLA Coordinates
LLA stands for a coordinate system that uses Latitude, Longitude, and Altitude, and is similar to a spherical coordinate system in that its origin is attached to the center of mass for the Earth and moves with the earth, except that it uses an obloid approximation of the Earth. The approximation is given by correction datums (see below).

 > * **Latitude**: Latitude of a point on Earth’s surface is the angle between the equatorial plane and the straight line passing through that point and the center of the Earth. Lines joining points of the same latitude trace circles on the surface of Earth called parallels, as they are parallel to the Equator and each other. The North pole is 90°N, and the South pole is 90°S. The 0° parallel of latitude is the Equator. It is denoted by &phi; and measured in degrees.
> * **Longitude**: Longitude is an angle pointing west or east from the Greenwich Meridian, which is the Prime Meridian. The longitude can be defined maximum as 180°E from the Prime Meridian and 180°W from the Prime Meridian. It is denoted by λ and measured in degrees.
> * **Altitude**: Altitude of a point is defined as height above the Earth’s surface. It is denoted by _h_ and measured in meters.

<pre align="center">
 <p align="center">
<img src=".\Images\LLACoordinates.png " alt="LLA coordinates" width="267" height="267">
<figcaption>Fig.2 - LLA coordinates.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

<br>

LLA coordinates, in their true definition, are spherical transformations assume the earth is a perfect sphere. And while it is close to a sphere, a better approximation is to use local ellipsoids to describe the surface - see the WGS specifications that follow. Note that, when LLA coordinates are given typically - for example from GPS receivers - they do NOT assume spherical coordinates and are given position assuming Geodetic Datums. This usage can be confusing, and thus good practice is to confirm the WGS datum, and whether it is being used, for ANY usage of LLA coordinates.

<a href="#wide-area-coordinate-systems">Back to top</a>

### WGS84 Geodetic Datum 
A geodetic datum is a coordinate system, and a set of reference points, used for locating places on the Earth (or similar objects) that are approximated by a particular shape (datum). An approximate definition of sea level on Earth is the datum "WGS 84", an ellipsoid. As the name implies, it was developed in 1984.

The coordinate origin of WGS 84 is meant to be located at the Earth's center of mass; the uncertainty in this position is believed to be less than 2cm.

The WGS 84 meridian of zero longitude is the IERS Reference Meridian, which is 5.3 arc seconds or 102 meters east of the Greenwich meridian, at the latitude of the Royal Observatory.

The WGS 84 datum surface is an oblate spheroid with:
> * Equatorial radius, a = 637,8137m at the equator, and
> * Flattening, f = 1/298.257223563. 

This leads to several computed parameters such as:

> * The polar semi-minor axis, b, which equals: a x (1 - f) = 6,356,752.3142m, and 
> * The first eccentricity squared, e²= 6.69437999014x10-3.

<pre align="center">
 <p align="center">
<img src=".\Images\WGS84.png " alt="WGS84 coordinates" width="267" height="267">
<figcaption>Fig.3 - LLA coordinates.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

<a href="#wide-area-coordinate-systems">Back to top</a>

## LL coordinates
The LL coordinate system system in WGS84 is actually the LLA coordinate system with altitude at every point equals zero i.e., h = 0. This is commonly used in "flattened" maps, which are often used for road maps (for example, Open Street Maps). One can add height information back into LL to produce LLA coordinates. For examples and methods on how to do this, see the Path Class library within IVSG.

<pre align="center">
 <p align="center">
<img src=".\Images\LLcoordinates.png " alt="LL coordinates" width="652" height="267">
<figcaption>Fig.4 (left) - LL coordinates are similar to LLA, but with height set to zero; Fig.5 (right)- LL coordinates are LLA with all heights at sea level.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

## ECEF Coordinates
Earth-centered, Earth-fixed Coordinates are also known as 3D Global Cartesian coordinates as they have a Cartesian basis. Specifically, every point that is expressed in ellipsoidal coordinates can be expressed as an rectilinear xyz (Cartesian) coordinate. Cartesian coordinates simplify many mathematical calculations. The Cartesian systems of different datums are not equivalent.

The Earth-centered Earth-fixed is also known as the ECEF, ECF, or conventional terrestrial coordinate system. It is assumed to rotate with the Earth and has its origin at the center of the Earth.

The conventional right-handed coordinate system puts:
> * The origin at the center of mass of the Earth, a point close to the Earth's center of figure
> * The Z axis on the line between the North and South Poles, with positive values increasing northward (but does not exactly coincide with the Earth's rotational axis)
> * The X and Y axes in the plane of the Equator
> * The X axis passing through extending from 180 degrees longitude at the Equator (negative) to 0 degrees longitude (prime meridian) at the Equator (positive)
> * The Y axis passing through extending from 90 degrees west longitude at the Equator (negative) to 90 degrees east longitude at the Equator (positive)

<pre align="center">
 <p align="center">
<img src=".\Images\ECEFcoordinates.png " alt="ECEF coordinates" width="332" height="267">
<figcaption>Fig.6 - ECEF coordinates are a cartesian frame that moves with the earth, useful for intermediate conversions between coordinate systems.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

[More info about ECEF](https://en.wikipedia.org/wiki/Geographic_coordinate_system#cite_note-Taylor2002-3)

<a href="#wide-area-coordinate-systems">Back to top</a>

## ENU Coordinates
ENU Coordinates are 3D Local Cartesian coordinates: East-North-Up (ENU). These are the most common coordinates used for local map representations, due to their intuitive relationship with the world.

* Every point that is expressed in ellipsoidal coordinates can be expressed as an rectilinear xyz (Cartesian) coordinate. Cartesian coordinates simplify many mathematical calculations. The Cartesian systems of different datums are not equivalent.
* A local tangent plane can be defined based on the vertical and horizontal dimensions. The vertical coordinate can point either up or down. 

There are two kinds of conventions for the frames:

> * East, North, up (ENU), used in geography
> * North, East, down (NED), used specially in aerospace

* In many targeting and tracking applications, the local ENU Cartesian coordinate system is far more intuitive and practical than ECEF or geodetic coordinates. The local ENU coordinates are formed from a plane tangent to the Earth's surface fixed to a specific location and hence it is sometimes known as a local tangent or local geodetic plane. By convention, the east axis is labeled x, the north y, and the up z.

<pre align="center">
 <p align="center">
<img src=".\Images\ENUcoordinates.png " alt="ENU coordinates" width="332" height="267">
<figcaption>Fig.7 - ENU coordinates are a local cartesian frame whose representation is strongly affected by the local origin.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

[More info about ENU](https://en.wikipedia.org/wiki/Geographic_coordinate_conversion#From_ECEF_to_ENU)

<a href="#wide-area-coordinate-systems">Back to top</a>

## UTM Coordinates
The 2D Transverse Mercator Projection, known more generally as the Universal Transverse Mercator (UTM), is a cylindrical rather than spherical projection of the earth. Specifically, the transverse Mercator (TM) projection is a conformal mapping of a reference ellipsoid of the earth onto a plane where the equator and central meridian remain as straight lines and the scale along the central meridian is constant; all other meridians and parallels being complex curves. The specific UTM is a mapping system that uses the TM projection with certain restrictions (such as standard 6°-wide longitude zones, the central meridian scale factor of 0.9996, defined false origin offsets, etc.)

* The origin for each zone is the intersection of its central meridian and the equator.
* Eastings are referenced from the central meridian of each zone, and northings from the equator, both in meters.
* The value given to the central meridian is the false easting, and to the equator is the false northing.
* A false easting of 500,000 meters is applied.
* A north zone has false northing of zero, while a south zone has false northing of 10,000,000 meters.

UTM coordinates are significantly distorted (non-isometric) and should be avoided when possible.

<pre align="center">
 <p align="center">
<img src=".\Images\UTMcoordinates.png " alt="UTM coordinates" width="617" height="267">
<figcaption>Fig.8 - UTM coordinates are a cylindrical rather than spherical projection, resulting in severe distortion.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

<a href="#wide-area-coordinate-systems">Back to top</a>

## STH Coordinates
Station-Transverse-Height (STH) coordinates, also called s-coordinates or Curvilinear Station Coordinates are coordinates that are attached to and move along a reference path. Thus, the station coordinate system applies along specific reference trajectories (for example, the center line of a road). S-coordinate systems are necessary for feedback control to a reference path, and are also used regularly for 3D immersive simulation tools. For example, they are the core coordinate system used in the ASAM OpenDrive standard.

This s-coordinate is commonly understood as position along a route, even if the motion along the route might not be exactly the same distance. For example, when someone runs a marathon and says that the race is 26.2 miles, the runners may actually run much farther as they weave side to side along the course (Dr. B's last marathon measured 27.3 miles, more than a mile longer than the offical course!). But the course itself is indeed laid out and measured very carefully to be 26.2 miles long in a particular path; this path defines the race's s-coordinate. 

Notably, the s-coordinate direction is almost never in a straight line but is rather used to measure motion along a path or distance traveled along a route. As a result, Newton's laws of motion do not apply to motions in this coordinate system, at least not without added correction factors.

The s-coordinate is a right-handed coordinate system. The following degrees of freedom are defined: 
> * s - "station" - the position along reference trajectory, measured in [m] from the beginning of the trajectory. The station is calculated along the arc length in the 3D or 2D coordinate from a particular origin.
> * t - "transverse" - the measurement of lateral position orthogonal to the direction of s, positive to the left keeping with the cross-product postive direction
> * h – "height", usually measured up from the road surface as zero.

<pre align="center">
 <p align="center">
<img src=".\Images\STHcoordinates.png " alt="STH coordinates" width="625" height="267">
<figcaption>Fig.9 - STH coordinates align with a particular reference path.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

And orientation can be defined:
> * heading around h-axis, 0 = forward 
> * pitch around t-axis, 0 = level 
> * roll around s -axis, 0 = level


<pre align="center">
 <p align="center">
<img src=".\Images\STHorientations.png " alt="STH orientations" width="625" height="267">
<figcaption>Fig.10 - STH orientations and their denoted name conventions.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

For feedback control, STH coordinates are particularly useful as the S parameter determines the travel the trajectory, and thus the longitudinal control whereas the T parameter determines the lateral offset and thus the steering command. 

Note that, in STH coordinates, distance along the path is important but can only be approximated. The path's arc length is the distance between two points along a section of a curve, and thus selection of a clear origin is essential. The STH reference curve can be approximated by connecting a finite number of points on the curve using line segments to create a polygonal path. See the Path Class library within IVSG for examples.

<a href="#wide-area-coordinate-systems">Back to top</a>

# Error Analysis

## Distance Metrics

### Euclidean distance
The Euclidean distance between two points in either the plane or 3-dimensional space measures the length of a segment connecting the two.

### Geodesic distance 
The shortest path between two points on the earth, customarily treated as an ellipsoid of revolution, is called a geodesic. A geodesic is the natural “straight line”, deﬁned as the line of minimum curvature, pinned to the surface of the earth.

<pre align="center">
 <p align="center">
<img src=".\Images\EuclideanVsGeodesicDistance.png " alt="Euclidean Vs Geodesic Distance" width="358" height="360">
<figcaption>Fig.11 - Comparison of Euclidean and Geodesic distances.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

### Station distance 
The station of a point B wrt A is the distance between A and B measured along the path. The distance measured along the path is the cumulative sum of distance metrics between intermediate points on the path. The distance metric is Euclidean in ENU, is not Euclidian OR Geodesic in UTM coordinate systems, and is Geodesic in LLA coordinate systems.

<pre align="center">
 <p align="center">
<img src=".\Images\StationDistance.jpg " alt="Euclidean Vs Geodesic Distance" width="1075" height="350">
<figcaption>Fig.12 - Station distance usually requires approximation of a curve length by a set of segments.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>


<a href="#wide-area-coordinate-systems">Back to top</a>

## Direct Conversion Errors
The following sections analyze the conversion errors between different coordinate frames, both in absolute distance and sometimes in station distance. For reference, the area tested extends over the largest test areas currently used within IVSG at Penn State, from the turn-around location near Altoona, to the State College area.

<pre align="center">
 <p align="center">
<img src=".\Images\StateCollegeToAltoona.png" alt="State College to Altoona Map" width="523" height="404">
<figcaption>Fig.13 - The State College to Altoona route (and back) represents the largest regular testing area used by IVSG, and this 50km route is the test area for the calculations below.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

The Geodesic calculations used the methods described in:
["Algorithms for geodesics" by Charles F.F. Karney](https://link.springer.com/article/10.1007/s00190-012-0578-z) with the WGS84 reference.
The UTM uses the Euclidean distance metric, also with the WGS84 ellipsoid.

The results illustrate that UTM corodinate systems are a poor choice if position accuracy is needed over wide areas.

### Geodetic vs UTM Distance Errors with Matched Station
Here, error in distance is measured from Geodetic (truth) to UTM (conversion). The resulting distance error ($e_d = d_{Geodetic} - d_{UTM}$) is approximately 14m at 50km of travel. Distance in Geodetic is the arc length, and the distance is the chord length in UTM. The altitude is forced to zero, and the station coordinates are matched to within 0.1 meters.

<pre align="center">
 <p align="center">
<img src=".\Images\GeodeticVsUTM.png" alt="Geodetic versus UTM" width="523" height="404">
<figcaption>Fig.14 - The distance errors that occur when matching stations after converting from Geodetic (true) to UTM.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>


<a href="#wide-area-coordinate-systems">Back to top</a>

### Geodetic vs UTM Station Errors with Matched Distance
Here, error in station is measured from Geodetic (truth) to UTM (conversion) at the same distances. The resulting station error ($e_d = s_{Geodetic} - s_{UTM}$) is approximately 13m at 50km of travel. The station in Geodetic is the cumulative arc length, and it is cumulative chord length in UTM. The altitude is forced to zero, and the distances are matched to within 0.1 meters.

<pre align="center">
 <p align="center">
<img src=".\Images\GeodeticVsUTMmatcheddistance.png" alt="Geodetic versus UTM matched distance" width="523" height="404">
<figcaption>Fig.15 - The distance errors that occur when matching distances after converting from Geodetic (true) to UTM.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>


<a href="#wide-area-coordinate-systems">Back to top</a>


# Installation

## Steps
To get a local copy up and running follow these simple steps.

1.  Make sure to run MATLAB 2020b or higher. Why? The "digitspattern" command used in the DebugTools utilities was released late 2020 and this is used heavily in the Debug routines. If debugging is shut off, then earlier MATLAB versions will likely work, and this has been tested back to 2018 releases.

2. Clone the repo
   ```sh
   git clone https://github.com/ivsg-psu/TrafficSimulators_WideAreaCoordinateSystems
   ```
3. Run the main code in the root of the folder. This will download the required utilities for this code, unzip the zip files into a Utilities folder (.\Utilities), and update the MATLAB path to include the Utility locations. This install process will only occur the first time. Note: to force the install to occur again, delete the Utilities directory and clear all global variables in MATLAB (type: "clear global *").
4. Confirm it works! Run the main demo script. If the code works, the script should run without errors. This script produces numerous example images such as those in this README file.


<!-- STRUCTURE OF THE REPO -->
## Directories
The following are the top level directories within the repository:
<ul>
	<li>/Documents folder: Descriptions of the functionality and usage of the various MATLAB functions and scripts in the repository.</li>
	<li>/Functions folder: The majority of the code for the point and patch association functionalities are implemented in this directory. All functions as well as test scripts are provided.</li>
	<li>/Utilities folder: Dependencies that are utilized but not implemented in this repository are placed in the Utilities directory. These can be single files but are most often folders containing other cloned repositories.</li>
</ul>

## Dependencies

(none)

<!-- FUNCTION DEFINITIONS -->

## Functions

<!--
**Basic Support Functions**
<ul>
	<li>
    fcn_Laps_plotLapsXY.m : This function plots the laps. For example, the function was used to make the plot below of the last Sample laps.
    <br>
    <img src=".\Images\fcn_Laps_plotLapsXY.png" alt="fcn_Laps_plotLapsXY picture" width="400" height="300">
    </li>
	<li>
    fcn_Laps_fillSampleLaps.m : This function allows users to create dummy data to test lap functions. The test laps are in general difficult situations, including scenarios where laps loop back onto themself and/or with separate looping structures. These challenges show that the library can work on varying and complicated data sets. NOTE: within this function, commented out typically, there is code to allow users to draw their own lap test cases.
    <br>
    <img src=".\Images\fcn_Laps_fillSampleLaps.png" alt="fcn_Laps_fillSampleLaps picture" width="400" height="300">
    </li>
    <li>
    fcn_Laps_plotZoneDefinition.m : Plots any type of zone, allowing user-defined colors. For example, the figure below shows a radial zone for the start, and a line segment for the end. For the line segment, an arrow is given that indicates which direction the segment must be crossed in order for the condition to be counted. 
    <br>
    <img src=".\Images\fcn_Laps_plotZoneDefinition.png" alt="fcn_Laps_plotZoneDefinition picture" width="400" height="300">
    </li>
    <li>
    fcn_Laps_plotPointZoneDefinition.m : Plots a point zone, allowing user-defined colors. This function is mostly used to support fcn_Laps_plotZoneDefinition.m 
    </li>
    <li>
    fcn_Laps_plotSegmentZoneDefinition.m : Plots a segment zone, allowing user-defined colors. This function is mostly used to support fcn_Laps_plotZoneDefinition.m 
    </li>
    
    

</ul>

**Core Functions**
<ul>
	<li>
    fcn_Laps_breakDataIntoLaps.m : This is the core function for this repo that breaks data into laps. Note: the example shown below uses radial zone definitions, and the results illustrate how a lap, when it is within a start zone, starts at the FIRST point within a start zone. Similarly, each lap ends at the LAST point before exiting the end zone definition. The input data is a traversal type for this particular function.
    <br>
    <img src=".\Images\fcn_Laps_breakDataIntoLaps.png" alt="fcn_Laps_breakDataIntoLaps picture" width="400" height="300">
    </li>	
	<li>
    fcn_Laps_checkZoneType.m : This function supports fcn_Laps_breakDataIntoLaps by checking if the zone definition inputs are either a point or line segment zone specification.
    </li>
	<li>
    fcn_Laps_breakDataIntoLapIndices.m : This is a more advanced version of fcn_Laps_breakDataIntoLaps, where the outputs are the indices that apply to each lap. The input type is also easier to use, a "path" type which is just an array of [X Y]. The example here shows the use of a segment type zone for the start zone, a point-radius type zone for the end zone. The results of this function are the row indices of the data. The plot below illustrates that the function returns 3 laps in this example, and as well returns the pre-lap and post-lap data. One can observe that it is common that the prelap data for one lap (Lap 2) consists of the post-lap data for the prior lap (Lap 1). 
    <br>
    <img src=".\Images\fcn_Laps_breakDataIntoLapIndices.png" alt="fcn_Laps_breakDataIntoLapIndices picture" width="600" height="300">
    </li>	
	<li>
    fcn_Laps_findSegmentZoneStartStop.m : A supporting function that finds the portions of a path that meet a segment zone criteria, returning the starting/ending indices for every crossing of a segment zone. The crossing must cross in the correct direction, and a segment is considered crossed if either the start or end of segment lie on the segment line. This is illustrated in the challenging example shown below, where the input path (thin blue) starts at the top, and then zig-zags repeatedly over a segment definition (green). For each time the blue line crosses the line segment, that portion of the path is saved as a separate possible crossing and thus, for this example, there are 5 possible crossings.
    <br>
    <img src=".\Images\fcn_Laps_findSegmentZoneStartStop.png" alt="fcn_Laps_findSegmentZoneStartStop picture" width="400" height="300">
    </li>	
	<li>
    fcn_Laps_findPointZoneStartStopAndMinimum.m : A supporting function that finds the portions of a path that meet a point zone criteria, returning the starting/ending indices for every crossing of a point zone. Note that a minimum number of points must be within the zone for it to be considered activated, which is useful for real-world data (such as GPS recordings) where noise may randomly push one point of a path randomly into a zone, and then jump out. This number of points threshold can be user-defined. In the example below, the threshold is 4 points and one can see that, for a path that crosses over the zone three times, that two of the crossings are found to meet the 4-point criteria.
    <br>
    <img src=".\Images\fcn_Laps_findPointZoneStartStopAndMinimum.png" alt="fcn_Laps_findPointZoneStartStopAndMinimum picture" width="400" height="300">
    </li>	
</ul>
Each of the functions has an associated test script, using the convention

```sh
script_test_fcn_fcnname
```
where fcnname is the function name as listed above.

As well, each of the functions includes a well-documented header that explains inputs and outputs. These are supported by MATLAB's help style so that one can type:

```sh
help fcn_fcnname
```
for any function to view function details.
-->

<!-- USAGE EXAMPLES -->
## Usage
<!-- Use this space to show useful examples of how a project can be used.
Additional screenshots, code examples and demos work well in this space. You may
also link to more resources. -->

<a href="#wide-area-coordinate-systems">Back to top</a>

### Examples

1. Run the main script to set up the workspace and demonstrate main outputs, including the figures included here:

   ```sh
   script_demo_Laps
   ```
    This exercises the main function of this code: fcn_Laps_breakDataIntoLaps

2. After running the main script to define the included directories for utility functions, one can then navigate to the Functions directory and run any of the functions or scripts there as well. All functions for this library are found in the Functions sub-folder, and each has an associated test script. Run any of the various test scripts, such as:

   ```sh
   script_test_fcn_Laps_breakDataIntoLapIndices
   ```
For more examples, please refer to the [Documentation](https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/tree/main/Documents)

# Useful References
### Precision chart for GPS
(the following is modified from: https://stackoverflow.com/questions/1947481/how-many-significant-digits-should-i-store-in-my-database-for-a-gps-coordinate

Accuracy and precision are often confused. Accuracy is the tendency of your measurements to agree with the true values. Precision is the degree to which the measurements increasingly specify a precise value. Precision without accuracy is useless - much like the joke about the museaum gude who was asked: "How old are these dinosaur bones?" And he answeres "30 million and 3 years old, because they were 30 million years old when I started working here 3 years ago." And accuracy without precision is also useless - like measuring a distance to the nearest millimeter but then rounding the result to the nearest kilometer. The balance of representing data is about an interplay of accuracy and precision. As a general principle, we don't need much more precision in recording data than there is accuracy built into them. Using too much precision can mislead people into believing the accuracy is greater than it really is.

Generally, when data is shown with degraded precision--that is, using fewer decimal places-- one can lose some accuracy. But how much? 

For GPS, it is relevant to know that the meter was originally defined (by the French, around the time of their revolution when they were throwing out the old systems and zealously replacing them by new ones) so that ten million meters would span, exactly, from the equator to a pole. The French wanted a standard that could not be controlled by any government, that anyone at any time could "check" should they wish. This is why the circumference of the Earth is almost exactly 40,000 km - a kilometer is defined FROM the circumference! As an aside, the people measuring this the first time had no idea the Earth was not EXACTLY a sphere, even at sea level, and it drove one of the two engineers toward a mental breakdown and eventual death (see the book, "The Measure of All Things", for the story of this).

So one can assume 10^7 meters, at sea level, spans almost exactly 90 degrees. So one degree of latitude covers about 10^7/90 = 111,111 meters. ("About," because the meter's length has changed a little bit in the meantime. But that change agrees with the original meter definition to many decimal places, so it doesn't much affect this approximation.) Furthermore, a degree of longitude (east-west) is about the same or less in length than a degree of latitude, because the circles of latitude shrink down to the earth's axis as we move from the equator towards either pole. Therefore, it's always safe to figure that the sixth decimal place in one decimal degree of latitude or longitude has at least 111,111/10^6 = about 1/9 meter = about 10 cm or 4 inches of precision. So the 6th decimal place is 10 cm, a handy number as, except for DGPS systems, this is about the best precision one will get with non-referenced GPS systems.

Accordingly, if our accuracy needs are, say, give or take 10 meters, than 1/9 meter is nothing: we lose essentially no accuracy by using six decimal places (but we may fill up our data storage with unnecessary digits). If our accuracy needs are sub-centimeter, then we need at least seven and probably eight or decimal places. 

The standard "long" formatting will typically show 13 decimal places or more for longitude or latitude. 13 decimal places will pin down the location to 111,111/10^13 = about 1 angstrom, around half the thickness of a small atom. This precision is impossible to achieve with current GPS systems, and thus such numbers are too precise.

Using these ideas we can construct a table of what each digit in a decimal degree signifies:

> * The **sign** tells us whether we are north or south, east or west on the globe.

> * A **nonzero hundreds digit** tells us we're using longitude, not latitude!

> * The **tens digit** gives a position to about 1,000 kilometers. It gives us useful information about what continent or ocean we are on.

> * The **units digit** (one decimal degree) gives a position up to 111 kilometers (60 nautical miles, about 69 miles). It can tell us roughly what large state or country we are in.

> * The **first decimal place** is worth up to 11.1 km: it can distinguish the position of one large city from a neighboring large city.

> * The **second decimal place** is worth up to 1.1 km: it can separate one village from the next.

> * The **third decimal place** is worth up to 110 m: it can identify a large agricultural field or institutional campus.

> * The **fourth decimal place** is worth up to 11 m: it can identify a parcel of land. It is comparable to the typical accuracy of an uncorrected GPS unit with no interference.

> * The **fifth decimal place** is worth up to 1.1 m: it distinguish trees from each other. Accuracy to this level with commercial GPS units can only be achieved with differential correction.

> * The **sixth decimal place** is worth up to 0.11 m: you can use this for laying out structures in detail, for designing landscapes, building roads. It should be more than good enough for tracking movements of glaciers and rivers. This can be achieved by taking painstaking measures with GPS, such as differentially corrected GPS.

> * The **seventh decimal place** is worth up to 11 mm: this is good for much surveying and is near the limit of what GPS-based techniques can achieve.

> * The **eighth decimal place** is worth up to 1.1 mm: this is good for charting motions of tectonic plates and movements of volcanoes. Permanent, corrected, constantly-running GPS base stations might be able to achieve this level of accuracy.

> * The **ninth decimal place** is worth up to 110 microns: we are getting into the range of microscopy. For almost any conceivable application with earth positions, this is overkill and will be more precise than the accuracy of any surveying device.

> * **Ten or more decimal places** indicates a computer or calculator was used and that no attention was paid to the fact that the extra decimals are useless. Be careful, because unless you are the one reading these numbers off the device, this can indicate low quality processing, and is often a hint that the data was collected, and reported, by someone who does not understand GPS systems.



### Definition of Endpoints

Add detail here on defining orgins of path stations, and on using the Laps library.

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.


## Major release versions
This code is still in development (alpha testing)


<!-- CONTACT -->
## Contact
Sean Brennan - sbrennan@psu.edu

Project Link: [hhttps://github.com/ivsg-psu/FeatureExtraction_DataClean_BreakDataIntoLaps](https://github.com/ivsg-psu/FeatureExtraction_DataClean_BreakDataIntoLaps)



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation.svg?style=for-the-badge
[contributors-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation.svg?style=for-the-badge
[forks-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/network/members
[stars-shield]: https://img.shields.io/github/stars/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation.svg?style=for-the-badge
[stars-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/stargazers
[issues-shield]: https://img.shields.io/github/issues/ivsg-psu/reFeatureExtraction_Association_PointToPointAssociationpo.svg?style=for-the-badge
[issues-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/issues
[license-shield]: https://img.shields.io/github/license/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation.svg?style=for-the-badge
[license-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/blob/master/LICENSE.txt







# Distance Metrics
* **Euclidean**: The Euclidean distance between two points in either the plane or 3-dimensional space measures the length of a segment connecting the two.
* **Geodesic**: The shortest path between two points on the earth, customarily treated as an ellipsoid of revolution, is called a geodesic. A geodesic is the natural “straight line”, deﬁned as the line of minimum curvature, for the surface of the earth.
* **Station**: Station of B wrt A is the distance between A and B measured along the path. The distance measured along the path is the cumulative sum of distance metrics between intermediate points on the path. The distance metric is Euclidean in ENU or UTM coordinate system, whereas the distance metric is Geodesic in LLA coordinate system.

<pre align="center">
<img src="https://github.com/ivsg-psu/TrafficSimulators/blob/master/Coordinate_Systems_Traffic_Simulator_Aimsun/Picture14.png" alt="distance Metrics" height="200" title="distance Metrics"/>          &nbsp;         <img src="https://github.com/ivsg-psu/TrafficSimulators/blob/master/Coordinate_Systems_Traffic_Simulator_Aimsun/Picture15.png" alt="distance Metrics" height="200" title="distance Metrics"/>
</pre>

# Difference analysis for each coordinate transformation

## Difference in distance measured in Geodetic and UTM is approximately 14m in 50km
Distance in Geodetic is the arc length, and the distance is the chord length in UTM 

<p align="center">
<img src="https://github.com/ivsg-psu/TrafficSimulators/blob/master/Coordinate_Systems_Traffic_Simulator_Aimsun/Picture17.png" alt="distance Metrics" height="100" title="distance Metrics"/>
<br>
𝛿𝑠≈0.1𝑚, 𝑎𝑙𝑡𝑖𝑡𝑢𝑑𝑒 𝑖𝑠 𝑧𝑒𝑟𝑜<br><br>
<img src="https://github.com/ivsg-psu/TrafficSimulators/blob/master/Coordinate_Systems_Traffic_Simulator_Aimsun/Picture18.png" alt="distance Metrics" height="90" width = "500" title="distance Metrics"/>
</p>
<br>
<pre align="center">
<img src="https://github.com/ivsg-psu/TrafficSimulators/blob/master/Coordinate_Systems_Traffic_Simulator_Aimsun/Picture19.png" alt="distance Metrics" height="350" title="distance Metrics"/>                <img src="https://github.com/ivsg-psu/TrafficSimulators/blob/master/Coordinate_Systems_Traffic_Simulator_Aimsun/Picture20.png" alt="distance Metrics" height="350" title="distance19Metrics"/>
</pre>

## Error in station measured in Geodetic and UTM is approximately 13m in 50km
The station in Geodetic is the cumulative arc length, and it is cumulative chord length in UTM.

<p align="center">
<img src="https://github.com/ivsg-psu/TrafficSimulators/blob/master/Coordinate_Systems_Traffic_Simulator_Aimsun/Picture17.png" alt="distance Metrics" height="100" title="distance Metrics"/>
<br>
𝛿𝑠≈0.1𝑚, 𝑎𝑙𝑡𝑖𝑡𝑢𝑑𝑒 𝑖𝑠 𝑧𝑒𝑟𝑜<br><br>
<img src="https://github.com/ivsg-psu/TrafficSimulators/blob/master/Coordinate_Systems_Traffic_Simulator_Aimsun/Picture21.png" alt="distance Metrics" height="90" width = "500" title="distance Metrics"/>
</p>
<br>
<pre align="center">
<img src="https://github.com/ivsg-psu/TrafficSimulators/blob/master/Coordinate_Systems_Traffic_Simulator_Aimsun/Picture22.png" alt="distance Metrics" height="350" title="distance Metrics"/>                <img src="https://github.com/ivsg-psu/TrafficSimulators/blob/master/Coordinate_Systems_Traffic_Simulator_Aimsun/Picture23.png" alt="distance Metrics" height="350" title="distance Metrics"/>
</pre>

## Distance: LLA vs ENU



<a href="url"><img src="https://github.com/ivsg-psu/TrafficSimulators/blob/master/Coordinate_Systems_Traffic_Simulator_Aimsun/Picture3.gif" alt="WGS84 point"  align="left" height="250" width="250" ></a>
[Refer to this document for more details](https://github.com/ivsg-psu/TrafficSimulators/blob/master/Coordinate_Systems_Traffic_Simulator_Aimsun/Coordinate_Systems_Traffic_Simulator_Aimsun.pptx)





