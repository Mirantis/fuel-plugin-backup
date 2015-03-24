# ceph rbd incremental snaphot backup

While Ceph has a wide range of use cases, the most frequent application that we are seeing is that of block devices as data store for public and private clouds managed by OpenStack, CloudStack, Eucalyptus, and OpenNebula. This means that we frequently get questions about things like geographic replication, backup, and disaster recovery (or some combination therein, given the amount of overlap on these topics). While a full-featured, robust solution to geo-replication is currently being hammered out there are a number of different approaches already being tinkered with (like Sebastien Han’s setup with DRBD or the upcoming work using RGW).

However, since one of the primary focuses in managing a cloud is the manipulation of images, the solution to disaster recovery and general backup can often be quite simplistic. Incremental snapshots can fill this, and several other, roles quite well. To that end I wanted to share a few thoughts from RBD developer Josh Durgin for those of you who may have missed his great talk at the OpenStack Developer Summit a few weeks ago.
For the purposes of disaster recovery, the idea is that you could run two simultaneous Ceph clusters in different geographic locations and instead of copying a new snapshot each time, you could simply generate and transfer a delta. The incantation would look something like this:
```
rbd export-diff --from-snap snap1 pool/image@snap2 pool_image_snap1_to_snap2.diff
```
This creates a simple binary file that stores the following information:
original snapshot name (if applicable)
end snapshot name
size of the image at ending snapshot
the diff between snapshots

The format of this file can be seen in the [RBD doc](http://ceph.com/docs/master/dev/rbd-diff/).

After exporting a diff you could either simply back up the file somewhere offsite or import the diff on top of the existing image on a remote Ceph cluster.
```
rbd import-diff /path/to/diff backup_image
```
This will write the contents of the differential to the backup image and create a snapshot with the same name as the original ending snapshot. It will fail and do nothing if a snapshot with this name already exists. Since overwriting the same data is idempotent, it’s safe to have an import-diff interrupted in the middle.
These commands can work with stdin and stdout as well, so you could do something like:
```
rbd export-diff --from-snap snap1 pool/image@snap2 - | ssh user@second_cluster rbd import-diff - pool2/image
```

You can see which extents changed (in plain text, json, or xml) via:
```
rbd diff --from-snap snap1 pool/image@snap2 --format plain
```
There are a couple of limitations in the current implementation, however.
There’s no guarantee you’re importing a diff onto an image in the right state (i.e. the same image at the same snapshot as the diff was exported from).
There’s no way to inspect the diff files to see what snapshots they refer to, so you’d have to depend on the filename containing that information.

While the implementation is still relatively simple, you can see how this could be quite useful in managing not only cloud images, but any of your Ceph block devices. This functionality hit the streets with the recent ‘cuttlefish‘ stable release, but if you have questions or enhancement requests please let us know.
To learn more about some of the new things coming in future versions of Ceph you can check out the current published roadmap of work Inktank is planning on contributing. Also if you missed the virtual Ceph Developer Summit, the videos have been posted for review. In the meantime, if you have questions, comments, or anything for the good of the cause feel free to stop by our irc channel or drop a note to one of the mailing lists.
