# Sample Project

![Sample Project Image](sample_project_img.jpg)

This project demonstrates how components tend to be structured using DTrack. All components are in their own directory inside the `components` folder. A couple components of interest:

**Card**: Contains a title, some content, and a set of numbers showing a rating. Demonstrates how rendering lists of data should be handled.

**Spinbox**: Increments or decrements a number, and constrains it to a range of values. Demonstrates how to use Anima to play animations when state changes occur.

**Root**: This is actually in the project root, not the `components` folder. This is the master component that controls the overall UI. A data class (`Review`) is used to store the state of a review. Whenever the list of reviews changes, the UI gets updated to reflect this. Two way bindings are used for the text inputs. This is a good component to base more complex components off of.