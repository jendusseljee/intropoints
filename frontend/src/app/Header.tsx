import { FaSignOutAlt } from 'react-icons/fa';
import Image from 'next/image';

export default function Header() {
  return (
    <header className="flex justify-center bg-primary p-4 text-white">
      <div className="flex w-page items-center justify-between">
        <div className="flex items-center space-x-2">
          <Image src="/thalia.svg" alt="Thalia logo" width={28} height={28} className="invert" />
          <h1 className="font-thalia text-3xl">INTROPOINTS</h1>
        </div>

        <button className="ml-auto flex w-10 justify-end" type="button">
          <FaSignOutAlt />
        </button>
      </div>
    </header>
  );
}
