## Custom Carbon Egg

SturdyStubs has also created a Custom Carbon Egg as well. This is a newer addition to the Carbon egg collection. This egg includes all of the Carbon builds, as well as a build for Oxide. This enables you to easily test the difference in performance between Oxide and Carbon. It also includes some great QoL features!

You can download the egg [here](https://raw.githubusercontent.com/SturdyStubs/Carbon.Egg/main/egg-rust--all-carbon-builds.json).

### Adding The Egg To The Nest

First we need to add the egg to the Rust nest. Here are the steps.

1. Login to the admin dashboard of your Pterodactyl panel installation.

2. Click on the "Nests" link in the side bar on the left.

3. Since there is already a "Rust" nest, we don't have to create a new one. Lets just go ahead and add the egg to the nest. Click on the green "Import Egg" button on the right.

4. Select the Custom Carbon Egg that you just downloaded by clicking browse, then navigate to the location you saved the egg to, and double click the file.

5. Next we need to select the "Rust" nest under the "Associated Nest" field.

   INSERT_IMPORT_EGG_ALL_CARBON_IMAGE

6. Now all we have to do is click on "Import".

### Installing the Server

This server installation guide is very similar to the Custom Rust Egg by MikeHawk, with some key differences. Some of the steps for installation might be the same. Please make sure to read these installation instructions throughly.

1. Log into your admin dashboard of your panel.

2. Navigate to your Servers by clicking on "Servers" on the side bar.

3. Click the "Create New" button on the right

4. Configure your server details in the "Core Details" section

5. For your port allocations you are going to need 1 main port, and 3 additional allocations. These allocations are for the Query Port, RCON Port, and App Port.

   INSERT_ALLOCATION_MANAGEMENT_IMAGE

6. Configure your "Application Feature Limits" and "Resource Management" sections to your liking

7. Under "Nest Configuration", select the "Rust" Nest

8. Then if your "Egg" field does not already say "Rust Carbon", change it to "Rust Carbon".

   INSERT_NEST_CONFIGURATION_ALL_CARBON_IMAGE

9. The "Docker Configuration" section can be skipped.

10. Next is the big part. The "Startup Configuration" section. In this section, you can fill out everything pretty much to your liking. However there are a few new options here that are not apart of the Default Rust Egg.

    1. Under the "Modding Framework" variable, you can choose different options for either Carbon, Oxide, or Vanilla. This is a combined version of the "Carbon Build" and "Minimal" variables from the other Custom Rust Egg by MikeHawk. The key difference here is this egg is also set up for the staging branch of Rust as well. The Staging Branch is only available with Carbon. See the "Difference Between Carbon Builds" section at the top of this page for more information.
    2. Lastly, the major difference between the Default Rust egg, and the Carbon Rust egg, is that you can set an IP address for your Rust+ App. This is critical in ensuring that your Rust+ connection is able to connect to the Rust+ API. Set this value to the public IP address of your server.
    3. Additionally, you can configure different Carbon root directories. This is good if you want to run a certain set of plugins on one map, but don't want to go through the hassle of copying and pasting over different configs for that map. All you have to do is just change your Carbon directory, and it will automatically switch over to those plugins, configs, and data files.

11. Do not forget to set your RCON, Query, and App ports to the appropriate ports that you assigned under the "Core Details" section. These ports should be equal to one of the three ports you assigned under your "Additional Ports" section.

12. Start your server by clicking the green "Create Server" button at the bottom of the page.

And that's it! You now have a Custom Carbon Rust server installed and ready to use!

## Credits to @BippyMiester for helping me create the egg