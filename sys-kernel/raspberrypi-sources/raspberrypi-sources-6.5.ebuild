# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_BASE_VER="6.5"
K_FROM_GIT="yes"
ETYPE="sources"
CKV="${PVR/-r/-git}"
EGIT_BRANCH="rpi-${K_BASE_VER}.y"
EGIT_COMMIT="fc9670ea2c8788ab21c25a8456cd38d729176fa3"

K_WANT_GENPATCHES="base extras experimental"
K_GENPATCHES_VER="10"
K_EXP_GENPATCHES_NOUSE="1"

# K_NODRYRUN="1"

# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"
inherit kernel-2 git-r3
detect_version

DESCRIPTION="The very latest -git version of the Linux kernel"
HOMEPAGE="https://www.kernel.org"
EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
SRC_URI="${GENPATCHES_URI}"

KEYWORDS="amd64 arm arm64"
IUSE="+naa +cachy +xanmod"

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/patch-2.7.6-r4"

src_unpack() {
	git-r3_src_unpack
	mv "${WORKDIR}/${PF}" "${S}"

	unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.base.tar.xz
        unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.extras.tar.xz
        unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.experimental.tar.xz
	rm -rfv "${WORKDIR}"/10*.patch
	rm -rfv "${WORKDIR}"/5010_enable-cpu-optimizations-universal.patch
	rm -rfv "${S}/.git"
}

src_prepare() {
	cp -v "${FILESDIR}/${K_BASE_VER}-networkaudio" ${K_BASE_VER}-networkaudio

	# genpatch
	eapply "${WORKDIR}"/*.patch

	# naa patch
	if use naa; then
		eapply "${FILESDIR}"/naa/*.patch
	fi

	# cachy patch
	if use cachy; then
	        eapply "${FILESDIR}/cachy/6.5/all/0001-cachyos-base-all.patch"
		eapply "${FILESDIR}/cachy/6.5/misc/0001-high-hz.patch"
	        eapply "${FILESDIR}/cachy/6.5/misc/0001-lrng.patch"
	fi

	# bmq patch
#	eapply "${FILESDIR}/cachy/6.5/sched/0001-prjc.patch"

	# xanmod patch
	if use xanmod; then
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/intel/0006-locking-rwsem-spin-faster.patch"

		eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

		eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0007-XANMOD-rcu-Change-sched_setscheduler_nocheck-calls-t.patch"
		eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0008-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0009-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
		eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0010-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
		eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0012-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
		eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0015-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0016-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"
		eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/xanmod/0017-XANMOD-Makefile-Disable-GCC-vectorization-on-trees.patch"
	fi

        eapply_user
}
