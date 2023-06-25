Frontend Boilerplate - HTML and CSS
===================================

This project is a frontend boilerplate that provides a starting point for developing web applications using HTML and CSS. It includes infrastructure as code (IaC) using Terraform to deploy an AWS CloudFront distribution and S3 bucket. Additionally, a GitHub Actions CD pipeline is already set up to streamline the deployment process.

Table of Contents
-----------------

-   [Features](https://chat.openai.com/#features)
-   [Installation](https://chat.openai.com/#installation)
-   [Deployment of Infrastructure](https://chat.openai.com/#deployment-of-infrastructure)
-   [Continuous Deployment (CD)](https://chat.openai.com/#continuous-deployment-cd)
-   [Usage](https://chat.openai.com/#usage)
-   [Contributing](https://chat.openai.com/#contributing)
-   [License](https://chat.openai.com/#license)
-   [Contact](https://chat.openai.com/#contact)

Features
--------

-   Frontend boilerplate for web applications using HTML and CSS
-   Infrastructure as Code (IaC) using Terraform
-   Automatic deployment through GitHub Actions CD pipeline
-   AWS CloudFront distribution and S3 bucket configuration
-   Efficient content delivery and caching through CloudFront

Installation
------------

Follow these steps to set up the project:

1.  Clone the repository and set up AWS credentials:


    ```
    git@github.com:alexrdrgz/vuejs-boilerplate.git 
    cd vuejs-boilerplate
    aws configure
    ```

    Follow the prompts to enter your AWS access key and secret key. Make sure you have the appropriate permissions to create and manage resources.

2.  Install project dependencies (if any).

Deployment of Infrastructure
----------------------------

To deploy the infrastructure and configure the AWS CloudFront distribution and S3 bucket, follow these steps:

1.  Update the `main.tf` file located in the `infrastructure` directory. Locate the `terraform` block and replace the backend configuration with your own S3 bucket information:

    `terraform { backend "s3" { bucket = "your-state-bucket" key = "frontend-boilerplate/terraform.tfstate" region = "us-west-2" } }`

    Replace `your-state-bucket` with the name of your own S3 bucket on your AWS account.

2.  Create a `variables.tfvars` file and set the following variables:

    `access_key = "" secret_key = "" domain_name = "boilerplate.alexrodriguez.link" route53_zone = "alexrodriguez.link"`

    Replace the placeholders for `access_key` and `secret_key` with your AWS access key and secret key. Make sure to keep the values in quotes.

3.  Initialize Terraform:

    `$ cd infrastructure $ terraform init`

    Terraform will now use the backend configuration specified in the `main.tf` file to store the state.

4.  Generate a Terraform plan to preview the changes:


    `$ terraform plan -var-file="variables.tfvars"`

    Review the plan to ensure it matches your expectations.

5.  Deploy the infrastructure:

    `$ terraform apply -var-file="variables.tfvars"`

    Once the deployment is complete, note the CloudFront distribution URL and S3 bucket endpoint for usage.

Continuous Deployment (CD)
--------------------------

This project includes a pre-configured GitHub Actions CD pipeline to automate the deployment process. To set up the CD pipeline, follow these steps:

1.  In your GitHub repository, navigate to the "Settings" tab.

2.  Select "Secrets" from the left sidebar.

3.  Add the following secrets:

    -   `AWS_ACCESS_KEY`: Set this to your AWS access key.
    -   `AWS_SECRET_KEY`: Set this to your AWS secret key.

    Make sure to secure these secrets by not exposing them in any public repositories.

4.  Navigate to the `.github/workflows/deploy.yml` file in your repository.

5.  Update the following line to replace `your-bucket-name` with your S3 bucket name, which should be the domain name of your site:

    `--bucket-name your-bucket-name`

6.  Commit and push the changes to trigger the CD pipeline.

The CD pipeline will automatically deploy your application whenever changes are pushed to the main branch.

Usage
-----

To start using the frontend boilerplate and begin developing your web application, follow these steps:

1.  Update the necessary HTML and CSS files to match your project requirements.

2.  Open the HTML file in a web browser to view the website locally during development.

Contributing
------------

We welcome contributions to enhance the boilerplate and make it more versatile. To contribute to the project, please follow these guidelines:

-   Submit bug reports or feature requests through the GitHub issue tracker.
-   Fork the repository, make your changes, and submit a pull request.

License
-------

This project is licensed under the [MIT License](https://chat.openai.com/LICENSE).

Contact
-------

If you have any questions or suggestions regarding this project, feel free to contact us:

-   Email: <your-email@example.com>
-   GitHub: your-username