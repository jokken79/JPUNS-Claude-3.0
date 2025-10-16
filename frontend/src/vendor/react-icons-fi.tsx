import React from 'react';
import {
  UsersIcon,
  BriefcaseIcon,
  CurrencyDollarIcon,
  DocumentTextIcon,
  CubeIcon,
  ArrowPathIcon,
  ArrowDownTrayIcon,
  ArrowUpTrayIcon,
  PlusIcon,
  PencilSquareIcon,
  TrashIcon,
  MagnifyingGlassIcon,
} from '@heroicons/react/24/outline';
import type { IconType } from './react-icons';

type HeroIconComponent = React.ComponentType<React.SVGProps<SVGSVGElement>>;

const withHeroIcon = (IconComponent: HeroIconComponent): IconType => {
  const WrappedIcon: IconType = ({ size = 24, ...props }) => (
    <IconComponent width={size} height={size} {...props} />
  );
  WrappedIcon.displayName = `HeroWrappedIcon(${IconComponent.displayName ?? IconComponent.name ?? 'Icon'})`;
  return WrappedIcon;
};

export const FiUsers = withHeroIcon(UsersIcon);
export const FiBriefcase = withHeroIcon(BriefcaseIcon);
export const FiDollarSign = withHeroIcon(CurrencyDollarIcon);
export const FiFileText = withHeroIcon(DocumentTextIcon);
export const FiPackage = withHeroIcon(CubeIcon);
export const FiRefreshCw = withHeroIcon(ArrowPathIcon);
export const FiDownload = withHeroIcon(ArrowDownTrayIcon);
export const FiUpload = withHeroIcon(ArrowUpTrayIcon);
export const FiPlus = withHeroIcon(PlusIcon);
export const FiEdit2 = withHeroIcon(PencilSquareIcon);
export const FiTrash2 = withHeroIcon(TrashIcon);
export const FiSearch = withHeroIcon(MagnifyingGlassIcon);
