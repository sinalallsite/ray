from ci.ray_ci.docker_container import DockerContainer

ECR = "029272617770.dkr.ecr.us-west-2.amazonaws.com"


class AnyscaleDockerContainer(DockerContainer):
    """
    Container for building and publishing anyscale docker images
    """

    def run(self) -> None:
        """
        Build and publish anyscale docker images
        """
        tag = self._get_canonical_tag()
        ray_image = f"rayproject/{self.image_type}:{tag}"
        anyscale_image = f"{ECR}/anyscale/{self.image_type}:{tag}"
        requirement = self._get_requirement_file()

        self.run_script(
            [
                # build image
                f"./ci/build/build-anyscale-docker.sh "
                f"{ray_image} {anyscale_image} {requirement}",
                # publish image
                "aws ecr get-login-password --region us-west-2 | "
                f"docker login --username AWS --password-stdin {ECR}",
                f"docker push {anyscale_image}",
            ]
        )

    def _get_requirement_file(self) -> str:
        prefix = "requirements" if self.image_type == "ray" else "requirements_ml"
        postfix = self.python_version

        return f"{prefix}_byod_{postfix}.txt"
